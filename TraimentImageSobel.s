############################################################################################################
#ARCHITECTURE----------------ZARIKIAN_HAYK_L2S3P_GROUPE_TD1---LIS_AMBRE_L2S3P_GROUPE_TD1----------------2021
############################################################################################################
            # WARNING : Le lancement du programme pour une image lourde pourrait durer très 
            # longtemps (2-3 min pour 256*256).
############################################################################################################
#-----------------------------------------------DONNEES-----------------------------------------------------
############################################################################################################

.data


    #####################################
    # DATA: Ouverture du fichier saisie #
    #####################################
    
    
    # Message pour l'attente de la saisie d'un nom de fichier d'entree
    WAIT_NAMEFILE_IN:                         .asciiz "Entrez le nom de votre fichier image au format BITMAP :\n"
    
    # Reservation d'une zone memoire pour enregistrer le nom du fichier saisi par l'utilisateur
    SAVE_NAMEFILE_IN:                         .space 25 
    
    # Reservation d'une zone memoire pour enregistrer le nom du fichier final dans le repertoire courant
    SAVE_NAMEFILE_OUT:                        .space 35
    
    # Mot a rajouter au nom du fichier d'entree pour son enregistrement
    ADD_NAME:                                 .asciiz "Contour.bmp"
    
    # Message d'erreur
    ERROR_MESSAGE:                            .asciiz "Une erreur est survenue due a la lecture/ecriture/ouverture du fichier.\nVeuillez verifier si le fichier se trouve dans le repertoire courant.\n"
                                              
    # Message d'incompatibilite
    NOT_SUPPORT_FORMAT:                       .asciiz "Ce format de fichier n'est pas pris en charge par le programme.\n" 
    
    
    #####################################
    #     DATA: l'en-tete du fichier    #
    #####################################
    
    
    # .align 2 : Pour l'identification du fichier BMP (2 octets)
    .align 2
    
    # Contient la taille totale du fichier
    FILE_TOTAL_SIZE:                           .space 4
    .align 4
    
    # Variable permettant le decalage de 4 octets
    FILE_NEXT_FOUR_BYTES:                      .space 4 
    .align 4
    
    # Contient l'offset de depart des donnees de l'image
    FILE_OFFSET_DATA:                          .space 4 
    .align 4
    
    
    #####################################
    #     DATA: l'en-tete de l'image    #
    #####################################
    
    
    # Contient la largeur de l'image en pixels
    PICTURE_WIDTH:                             .space 4
    .align 4
    
    # Contient la hauteur de l'image en pixels
    PICTURE_HEIGHT:                            .space 4
    .align 4
    
    # Variable permettant le decalage de 2 octets
    PICTURE_NEXT_TWO_BYTES:                    .space 2
    .align 2
    
    # Contient le nombre de bits utilises pour coder la couleur
    PICTURE_NBBYTES_CODING_COLOR:              .space 2
    .align 4
    
        
.text
.globl __start


############################################################################################################
#-------------------------------------------------MAIN------------------------------------------------------
############################################################################################################


###################################
#           Bonjour :)            #
################################### 


__start:


###################################
#   Ouverture du fichier saisie   #
###################################


# Affiche une chaine de caractère demandant d'entrer le nom du fichier BITMAP
    la $a0, WAIT_NAMEFILE_IN   # charge une chaine de caractere dans $a0
    jal printString          
    
# Insertion de l'image par l'utilisateur
    la $a0, SAVE_NAMEFILE_IN   # charge le fichier d'entree dans $a0
    jal insertFileName 
    
# Suppresion du caractere '\n'
    jal deleteEnter            # supprime le caractere d'entree
        
# Ouverture du fichier BITMAP
    la $a0, SAVE_NAMEFILE_IN   # charge dans $a0 le fichier d'entree 
    li $a1, 0                  # descripteur de fichier 0 pour lecture
    jal openFile               
    move $s0 $v0               # enregistrement du descripteur de fichier dans $s0
    
# Enregistrement du nom de fichier de sortie
    jal outputFileName 
    

###################################
# Lecture de l'en-tete du fichier #
###################################


# Verification : fichier Bitmap : Oui ou Non 
    jal formatBitmapYesOrNo 
    
# Lecture de la taille totale du fichier BITMAP
    jal readFileTotalSize

# Decalage de 4 octets
    jal readNextFourBytesUnusable

# Lecture de l'offset
    jal readOffset
    
    
###################################
# Lecture de l'en-tete de l'image #
###################################


# Decalage de 4 octets
    jal readNextFourBytesUnusable
    
# Lecture de la largeur de l'image en pixels
    jal readWidth

# Lecture de la hauteur de l'image en pixels
    jal readHeight

# Decalage de 2 octets
    jal readNextTwoBytesUnusable
    
# Lecture du nombre de bits utilises pour coder la couleur
    jal readNbBytesCodingColor


###################################
#     Traitement de l'image       #
###################################  

# Fermeture du fichier BITMAP
    move $a0, $s0 # close file descriptor
    jal closeFile
    
# Ouverture du fichier d'entree
    la $a0 SAVE_NAMEFILE_IN
    li $a1 0
    li $a2 0
    jal openFile
    move $s0 $v0
    
# Ouverture du fichier de sortie
    la $a0 SAVE_NAMEFILE_OUT
    li $a1 1
    li $a2 0
    jal openFile
    move $s2 $v0
    
# Ecriture de l'en-tête de l'image dans l'image de sortie
    # Allocation et stockage
    la $a1 FILE_OFFSET_DATA
    lw $a0 0($a1)
    move $s1 $a0 # $s1 = NB OFFSET
    
    # Lecture de l'offset
    jal ReadOffset
    
    # Ecriture dans l'image de sortie
    move $a0 $s2
    move $a1 $s3
    move $a2 $s1
    jal writeFile
    
# Traitement de l'image
   # Allocation, stockage et lecture
    la $a1 FILE_TOTAL_SIZE
    lw $a0 0($a1)
    move $s4 $a0
    
    # Soustrait l'offset de la taille totale
    subu $s4 $s4 $s1
    
    # Espace mémoire : Image originale
    jal copyPictureOriginal
    
    # Fermeture du fichier BITMAP
    move $a0, $s0 # fermeture du fichier d'entrée
    jal closeFile
    
    subu $sp $sp 8
    
    # Espace mémoire 1 : GX
    li $v0 9
    move $a0 $s4
    syscall
    sw $v0 0($sp)
    
    # Espace mémoire 2 : GY
    li $v0 9
    move $a0 $s4
    syscall
    sw $v0 4($sp)
    
###################################
#       Ecriture de l'image       #
################################### 

        
# Stockage de la largeur
    la $a1 PICTURE_WIDTH
    lw $a0 0($a1)
    move $s1 $a0 

# Stockage de la hauteur
    la $a1 PICTURE_HEIGHT
    lw $a0 0($a1)
    move $s6 $a0 
    
# Les tableaux d'image
    # Tableau 0 : 0($sp) : GX
        lw $a0 0($sp)
        move $t0 $a0
    
    # Non utilisé dans notre solution de filtrage : Tableau 1 : 4($sp) : GY 
        lw $a0 4($sp)
        move $t1 $a0
        
        
# Decalage de la ligne (255,..) pour le tableau 0 : mettre (00)  
    jal nextWidthBytesTable

# Application du filtre de Sobel
    jal sobelFilter
    
# Ecriture de l'image
    move $a0 $s2
    lw $a1 0($sp)
    move $a2 $s4
    jal writeFile
    
    addu $sp $sp 8
   
# Fermeture des fichiers
    move $a0 $s1 # fermeture du fichier de sortie
    jal closeFile
   
   
###################################
#         au revoir :)            #
################################### 


# Quitte le programme
    j Exit
    
 
############################################################################################################
#-----------------------------------------------FONCTION----------------------------------------------------
############################################################################################################


#///////////////////////////////////////////////////////////////////////////////////////////////////////////

# Fonction qui affiche une chaine de caractere
printString:
    # Prologue
    subu $sp $sp, 8
    sw $ra, 0($sp)
    sw $a0, 4($sp)
    
    #Corps
    li $v0, 4 # syscode -> 4 : print string
    syscall 
    
    # Epilogue
    lw $a0, 4($sp)
    lw $ra, 0($sp)
    addu $sp $sp, 8
    jr $ra
    
#///////////////////////////////////////////////////////////////////////////////////////////////////////////
    
# Fonction permettant l'insertion du fichier BITMAP par l'utilisateur
insertFileName:
    # Prologue
    subiu $sp $sp, 8
    sw $ra, 0($sp)
    sw $a0, 4($sp)
    
    # Corps
    la $a1, 25 # max character 25 for input file
    li $v0, 8  # syscode -> 8 : read string
    syscall
    
    # Epilogue
    lw $a0, 4($sp)
    lw $ra, 0($sp)
    addu $sp $sp, 8
    jr $ra

#///////////////////////////////////////////////////////////////////////////////////////////////////////////

# Supprime le caractere '\n' due a l'insertion du fichier dans le cas contraire la detection du fichier
# est mauvaise. En tapant "lena256.bmp", le programme cherche "lena256.bmp\n" car pendant la saisie
# nous appuyons sur la touche "entrer" du clavier qui est comptabilisee dans la saisie.
deleteEnter:
    # Prologue
    subiu $sp $sp, 8
    sw $ra, 0($sp)
    sw $a0, 4($sp)
    
    # Corps
    move $t0 $a0                   # $t0 = SAVE_NAMEFILE_IN 
    li $t1, 10                     # ASCII 10 (LINE FEED) : '\n'       
    li $t2, 0                      # ASCII 0 (NULL) : '\0'
    
# Début de la boucle        
startSearchLoop:
    lb $t3, 0($t0)                 # table of $t0 -> SAVE_NAMEFILE_IN
    beqz $t3 endSearchLoop         # if $t3 == '\0' -> end loop : endSearchLoop
        beq $t3 $t1 deleteChar     # if $t3 == '\n' -> deleteChar
            addi $t0 $t0, 1        # $t0 = $t0 + 1 
            j startSearchLoop      # loop -> startSearchLoop
            
# Supression du caractère '\n'
deleteChar: 
    sb $t2, 0($t0)                 # replace character '\0' in character '\n'
    j endSearchLoop                # end loop : endSearchLoop
            
# Fin de la boucle
endSearchLoop:
    move $v0 $a0                   # return SAVE_NAMEFILE_IN without '\n'
    
    # Epilogue
    lw $a0, 4($sp)
    lw $ra, 0($sp)
    addiu $sp $sp, 8
    jr $ra
    
#///////////////////////////////////////////////////////////////////////////////////////////////////////////

# Ouverture du fichier BITMAP
openFile:
    # Prologue
    subiu $sp $sp, 12
    sw $ra, 0($sp)
    sw $a0, 4($sp)
    sw $a1, 8($sp)
    
    # Corps
    li $v0, 13                 # syscode -> 13 : open file 
    syscall 
    
    # Detection fichier introuvable dans le repertoire courant
    bltz $v0 ErrorFileMessage # if file don't found -> v0 < 0 (fonction : error) else jump (fonction : pass)
        j openFilePass        # jump openFilePass
         
openFilePass:
    # Epilogue
    lw $a1, 8($sp)
    lw $a0, 4($sp)
    lw $ra, 0($sp)
    addiu $sp $sp, 12
    jr $ra

#///////////////////////////////////////////////////////////////////////////////////////////////////////////

# Fonction qui recupere le nom du fichier d'entree copie dans le nom du fichier de sortie sans l'extension
# (.bmp) puis rajoute le mot "Contour.bmp".
outputFileName:
    # Prologue
    subiu $sp $sp, 16
    sw $ra, 0($sp)
    sw $a0, 4($sp)
    sw $a1, 8($sp)
    sw $a2, 12($sp)
    
    
    # Corps
    la $a0 SAVE_NAMEFILE_IN         # charge SAVE_NAMEFILE_IN in $a0
    la $a1 SAVE_NAMEFILE_OUT        # charge SAVE_NAMEFILE_OUT in $a1
    la $a2 ADD_NAME                 # charge ADD_NAME in $a2
    
    move $t0 $a0                    # charge $a0 in $t0
    move $t1 $a1                    # charge $a1 in $t1
    move $t2 $a2                    # charge $a2 in $t2
    
    li $t3, 46                      # ASCII 46 : '.'
    li $t4, 11                      # counter max : 11
    li $t5, 0                       # init 0
    
# Boucle qui récupére le nom d'entré du fichier sans l'extension (.bmp)
outputFileNameLoop:
    lb $t6, 0($t0)                  # table of $t0 -> SAVE_NAMEFILE_IN
    beq $t6 $t3 addStringContourBmp # Search point(.) : if $t6 == $t3 -> jump addStringContourBmp
        sb $t6, 0($t1)              # store $t6 in $t1
        addi $t0 $t0, 1             # $t0 = $t0 + 1
        addi $t1 $t1, 1             # $t1 = $t1 + 1
        j outputFileNameLoop        # jump outputFileNameLoop
        
# Ajoute le mot "Contour.bmp" en faisant une boucle avec un compteur de 0 à 11       
addStringContourBmp:
    beq $t5 $t4 outputFileNamePass  # if $t5 == $t4 -> jump outputFileNamePass
        lb $t7, 0($t2)              # table of $t2 -> ADD_NAME
        sb $t7, 0($t1)              # store $t7 in $t1
        addi $t1 $t1, 1             # $t1 = $t1 + 1
        addi $t2 $t2, 1             # $t2 = $t2 + 1
        addi $t5 $t5, 1             # $t5 = $t5 + 1
        j addStringContourBmp       # jump addStringContourBmp
    
outputFileNamePass:   
    # Epilogue
    lw $ra, 0($sp)
    lw $a0, 4($sp)
    lw $a1, 8($sp)
    lw $a2, 12($sp)
    addi $sp $sp, 16
    jr $ra
    
#///////////////////////////////////////////////////////////////////////////////////////////////////////////

# Allocation $a0 octets dans le tas
allocBytes:
    # Prologue
    subiu $sp $sp, 8
    sw $ra, 0($sp)
    sw $a0, 4($sp)
    
    # Corps
    li $v0, 9 # syscode -> 9 : sbrk (allocate heap memory)
    syscall 
    
    # Epilogue
    lw $a0, 4($sp)
    lw $ra, 0($sp)
    addiu $sp $sp, 8
    jr $ra

#///////////////////////////////////////////////////////////////////////////////////////////////////////////

# Lecture du fichier BITMAP
readFile:
    # Prologue
    subiu $sp $sp, 16
    sw $ra, 0($sp)
    sw $a0, 4($sp)
    sw $a1, 8($sp)
    sw $a2, 12($sp)
    
    # Corps
    move $a0 $s0               # $a0 = file descriptor -> 0 (read)
    li $v0, 14                 # syscode -> 14 : read from file
    syscall
    
    bltz $v0, ErrorFileMessage # if file don't found -> v0 < 0 (fonction : error) else jump (fonction : pass)
        j readFilePass         # jump readFilePass
        
readFilePass:
    # Epilogue
    lw $ra, 0($sp)
    lw $a0, 4($sp)
    lw $a1, 8($sp)
    lw $a2, 12($sp)
    addiu $sp $sp, 16
    jr $ra
   
#///////////////////////////////////////////////////////////////////////////////////////////////////////////

# Fonction qui alloue un espace memoire dans $s1 de 2 octets pour ensuite verifier si le fichier saisie est
# bien un fichier BITMAP, si c'est le cas alors la fonction passe sinon elle affiche un message d'erreur.
formatBitmapYesOrNo:
    # Prologue
    subiu $sp $sp, 20
    sw $ra, 0($sp)
    sw $a0, 4($sp)
    sw $a1, 8($sp)
    sw $a2, 12($sp)
    sw $s1, 16($sp)
    
    # Corps
    # Allocation de 2 octets pour l'identification du fichier BITMAP
    li $a0, 2                           # 2 bytes
    jal allocBytes                      # allocation
    move $s1 $v0                        # $s1 : memory space -> 2 bytes
    
    # Lecture des 2 premiers octets 
    move $a1 $s1                        # charge $s1 in $a1
    li $a2, 2                           # 2 bytes
    jal readFile                        # read 2 bytes from file
    
    # Vérification fichier BITMAP
    move $t0 $s1                        # $t0 = $s1 
    li $t1, 66                          # ASCII 66 (deci) : 42 (hexa)
    li $t2, 77                          # ASCII 77 (deci) : 4d (hexa)
    
# Début de la boucle        
formatBitmapYesOrNoLoop:
    lb $t3, 0($t0)                      # table of $t0 -> $s1
    beq $t3 $t1 nextByte                # if $t3 == $t1 -> $t3 == 42 (hex) : nextByte
        j NotSupportFormatMessage       # else jump ErrorFileMessage
                   
nextByte: 
    lb $t3, 1($t0)                      # table : charge 1($t0) in $t3
    beq $t3 $t2 formatBitmapYesOrNoPass # if $t3 == $t2 -> $t3 == 4d (hex) : formatBitmapYesOrNoPass
        j NotSupportFormatMessage       # else jump ErrorFileMessage
            
formatBitmapYesOrNoPass:
    # Epilogue
    lw $ra, 0($sp)
    lw $a0, 4($sp)
    lw $a1, 8($sp)
    lw $a2, 12($sp)
    lw $s1, 16($sp)
    addiu $sp $sp, 20
    jr $ra
    
# Fonction qui affiche un message d'incompatibilite
NotSupportFormatMessage:
    la $a0 NOT_SUPPORT_FORMAT
    jal printString
    j Exit
   
#///////////////////////////////////////////////////////////////////////////////////////////////////////////

# Fonction qui récupére la taille totale du fichier dans la variable FILE_TOTAL_SIZE
readFileTotalSize: 
    # Prologue
    subiu $sp $sp, 12
    sw $ra, 0($sp)
    sw $a1, 4($sp)
    sw $a2, 8($sp)
    
    # Corps
    la $a1 FILE_TOTAL_SIZE # charge FILE_TOTAL_SIZE in $a1
    li $a2, 4              # charge 4 in $a2
    jal readFile           # jump and link -> readFile
    
    # Epilogue
    lw $a2, 8($sp)
    lw $a1, 4($sp)
    lw $ra, 0($sp)
    addiu $sp $sp, 12
    jr $ra

#///////////////////////////////////////////////////////////////////////////////////////////////////////////

# Fonction qui recupere l'offset dont les donnees de l'image commence
readNextFourBytesUnusable:
    # Prologue
    subiu $sp $sp, 12
    sw $ra, 0($sp)
    sw $a1, 4($sp)
    sw $a2, 8($sp)
    
    # Corps
    la $a1 FILE_NEXT_FOUR_BYTES # charge FILE_NEXT_FOUR_BYTES in $a1
    li $a2, 4                   # charge 4 in $a2
    jal readFile                # jump and link -> readFile
    
    # Epilogue
    lw $a2, 8($sp)
    lw $a1, 4($sp)
    lw $ra, 0($sp)
    addiu $sp $sp, 12
    jr $ra
    
#///////////////////////////////////////////////////////////////////////////////////////////////////////////

# Fonction qui recupere l'offset dont les donnees de l'image commence
readOffset:
    # Prologue
    subiu $sp $sp, 12
    sw $ra, 0($sp)
    sw $a1, 4($sp)
    sw $a2, 8($sp)
    
    # Corps
    la $a1 FILE_OFFSET_DATA # charge FILE_OFFSET_DATA
    li $a2, 4               # charge 4 in $a2
    jal readFile            # jump and link -> readFile
    
    # Epilogue
    lw $a2, 8($sp)
    lw $a1, 4($sp)
    lw $ra, 0($sp)
    addiu $sp $sp, 12
    jr $ra

#///////////////////////////////////////////////////////////////////////////////////////////////////////////

# Fonction qui recupere la largeur de l'image en pixels
readWidth:
    # Prologue
    subiu $sp $sp, 12
    sw $ra, 0($sp)
    sw $a1, 4($sp)
    sw $a2, 8($sp)
    
    # Corps
    la $a1 PICTURE_WIDTH # charge FILE_WIDTH in $a1
    li $a2, 4         # charge 4 in $a2
    jal readFile      # jump and link -> readFile
    
    # Epilogue
    lw $a2, 8($sp)
    lw $a1, 4($sp)
    lw $ra, 0($sp)
    addiu $sp $sp, 12
    jr $ra

#///////////////////////////////////////////////////////////////////////////////////////////////////////////

# Fonction qui recupere la hauteur de l'image en pixels
readHeight:
    # Prologue
    subiu $sp $sp, 12
    sw $ra, 0($sp)
    sw $a1, 4($sp)
    sw $a2, 8($sp)
    
    # Corps
    la $a1 PICTURE_HEIGHT # charge FILE_HEIGHT in $a1
    li $a2, 4          # charge 4 in $a2
    jal readFile       # jump and link -> readFile
    
    # Epilogue
    lw $a2, 8($sp)
    lw $a1, 4($sp)
    lw $ra, 0($sp)
    addiu $sp $sp, 12
    jr $ra

#///////////////////////////////////////////////////////////////////////////////////////////////////////////

# Fonction qui decale la lecture de 2 octets 
readNextTwoBytesUnusable:
    # Prologue
    subiu $sp $sp, 12
    sw $ra, 0($sp)
    sw $a1, 4($sp)
    sw $a2, 8($sp)
    
    # Corps
    la $a1 PICTURE_NEXT_TWO_BYTES  # charge FILE_NEXT_FOUR_BYTES in $a1
    li $a2, 2                   # charge 2 in $a2
    jal readFile                # jump and link -> readFile
    
    # Epilogue
    lw $a2, 8($sp)
    lw $a1, 4($sp)
    lw $ra, 0($sp)
    addiu $sp $sp, 12
    jr $ra
    
#///////////////////////////////////////////////////////////////////////////////////////////////////////////

# Fonction qui recupere le nombre de bits utilises pour coder la couleur d'un pixel
readNbBytesCodingColor:
    # Prologue
    subiu $sp $sp, 12
    sw $ra, 0($sp)
    sw $a1, 4($sp)
    sw $a2, 8($sp)
    
    # Corps
    la $a1 PICTURE_NBBYTES_CODING_COLOR  # charge FILE_NBBYTES_CODING_COLOR in $a1
    li $a2, 2                         # charge 2 in $a2
    jal readFile                      # jump and link -> readFile
    
    # Epilogue
    lw $a2, 8($sp)
    lw $a1, 4($sp)
    lw $ra, 0($sp)
    addiu $sp $sp, 12
    jr $ra
    
#///////////////////////////////////////////////////////////////////////////////////////////////////////////

# Fermeture du fichier BITMAP
closeFile:
    # Prologue
    subiu $sp $sp, 12
    sw $ra, 0($sp)
    sw $a0, 4($sp)
    sw $s0, 8($sp)
    
    # Corps
    li $v0, 16 # syscode -> 16 : close file
    syscall
    
    # Epilogue
    lw $s0, 8($sp)
    lw $a0, 4($sp)
    lw $ra, 0($sp)
    addiu $sp $sp, 12
    jr $ra
    
#///////////////////////////////////////////////////////////////////////////////////////////////////////////

# Fonction qui permet la lecture de l'offset
ReadOffset:
    # Prologue
    subiu $sp $sp, 12
    sw $ra, 0($sp)
    sw $a0, 4($sp)
    sw $s0, 8($sp)
    
    # Corps
    # Allocation de l'en-tete de l'image
    move $a0, $s1  # charge $s1 in $a0
    jal allocBytes # jump and link -> allocBytes
    move $s3 $v0   # charge $v0 in $s3
    
    move $a1 $s3   # charge $s3 in $a1
    move $a2 $s1   # charge $s1 in $a2
    jal readFile   # jump and link -> readFile
    
    # Epilogue
    lw $s0, 8($sp)
    lw $a0, 4($sp)
    lw $ra, 0($sp)
    addiu $sp $sp, 12
    jr $ra

#///////////////////////////////////////////////////////////////////////////////////////////////////////////

# Fonction qui permet l'ecriture de fichier
writeFile:
    # Prologue
    subiu $sp $sp, 16
    sw $ra, 0($sp)
    sw $a0, 4($sp)
    sw $a1, 8($sp)
    sw $a2, 12($sp)
    
    # Corps
    li $v0, 15 # syscode -> 15 : write file
    syscall
    
    # Epilogue
    lw $ra, 0($sp)
    lw $a0, 4($sp)
    lw $a1, 8($sp)
    lw $a2, 12($sp)
    addiu $sp $sp, 16
    jr $ra

#///////////////////////////////////////////////////////////////////////////////////////////////////////////

# Fonction qui copie l'image originale dans $s5 
copyPictureOriginal:
    # Prologue
    subiu $sp $sp, 12
    sw $ra, 0($sp)
    sw $a0, 4($sp)
    sw $s0, 8($sp)
    
    # Corps
    # Allocation 
    move $a0 $s4   # charge $s4 in $a0
    jal allocBytes # jump and link -> allocBytes
    move $s5 $v0   # charge $v0 in $s5
    
    # $s5 contient l'image originale
    move $a1 $s5   # charge $s5 in $a1
    move $a2 $s4   # charge $s4 in $a2
    jal readFile   # ju:mp and link -> readFile
    
    # Epilogue 
    lw $s0, 8($sp)
    lw $a0, 4($sp)
    lw $ra, 0($sp)
    addiu $sp $sp, 12
    jr $ra
    
#///////////////////////////////////////////////////////////////////////////////////////////////////////////

# Fonction qui décale la ligne (255,..) car = 00
nextWidthBytesTable:
    # Prologue
    subu $sp $sp, 8
    sw $ra, 0($sp)
    sw $a0, 4($sp)
    
    # Corps
    li $t3 0
    
startNextWidthBytesTableLoop:
    beq $t3 $s1 startNextWidthBytesTableLoopPass # if $t3 == $s1 (width) -> pass
    addi $t3 $t3 1
    addi $t0 $t0 1
    j startNextWidthBytesTableLoop
    
startNextWidthBytesTableLoopPass:
    # Epilogue
    lw $a0, 4($sp)
    lw $ra, 0($sp)
    addu $sp $sp, 8
    jr $ra

#///////////////////////////////////////////////////////////////////////////////////////////////////////////

# Fonction qui parcours la hauteur et la largeur de l'image qui ensuite utilise
# FX et FY pour trouver le resultat GX et GY dans une meme boucle. De plus, 
# nous avons fait en sorte d'additionner GX et GY directement dans la fonction
# ce qui nous permet de realiser le filtre en une fonction, nous avons bien 
# pris en compte le seuillage et la valeur absolue des resultats négatifs.
sobelFilter:
    # Prologue
    subu $sp $sp, 16
    sw $ra, 0($sp)
    sw $s1, 4($sp)
    sw $s5, 8($sp)
    sw $s6, 12($sp)
    
    # Corps
    # Variable
    li $t3 2 # compteur colonne
    li $t4 2 # compteur ligne
    li $t6 0 # resultat pour l'image finale
    
# Parcours nombre de hauteur - 2 car la ligne (0,..) et (255,..) = 00 
startSobelFilterLineLoop:
    beq $t4 $s6 startSobelFilterLineLoopPass
# Parcours nombre de largeur -2 car la colonne (..,0) et (..,255) = 00
startSobelFilterColumnLoop:
    beq $t3 $s1 startSobelFilterColumnLoopPass
        li $t9 0 # resultat GX
        li $t6 0 # resultat GX + GY
        
        # Premiere partie de la matrice
            # Pour FX : stockage du résultat dans $t6
            lb $t5 0($s5)
            mul $t5 $t5 -1
            add $t6 $t6 $t5
        
            lb $t5 2($s5)
            add $t6 $t6 $t5
            # Pour FY : stockage du resultat dans $t9
            lb $t2 0($s5)
            mul $t2 $t2 -1
            add $t9 $t9 $t2
            
            lb $t2 1($s5)
            mul $t2 $t2 -2
            add $t9 $t9 $t2
            
            lb $t2 2($s5)
            mul $t2 $t2 -1
            add $t9 $t9 $t2
            
        # Deuxieme partie de la matrice
            # Decalage d'une ligne pour l'image originale
            li $t8 0 
startLine1FeedLoop:
            beq $t8 $s1 startLine1FeedLoopPass
                addi $s5 $s5 1
                addi $t8 $t8 1
                j startLine1FeedLoop   
startLine1FeedLoopPass:
            # Pour FX : stockage du resultat dans $t6
            lb $t5 0($s5)
            mul $t5 $t5 -2
            add $t6 $t6 $t5 
            
            lb $t5 2($s5)
            mul $t5 $t5 2
            add $t6 $t6 $t5
            
        # Derniere partie de la matrice
            # Decalage d'une ligne pour l'image originale
            li $t8 0
startLine2FeedLoop:
    beq $t8 $s1 startLine2FeedLoopPass
        addi $s5 $s5 1
        addi $t8 $t8 1
        j startLine2FeedLoop   
startLine2FeedLoopPass:
            # Pour FX : stockage du resultat dans $t6
            lb $t5 0($s5)
            mul $t5 $t5 -1
            add $t6 $t6 $t5
            
            lb $t5 2($s5)
            add $t6 $t6 $t5
            # Pour FY : stockage du resultat dans $t9
            lb $t2 0($s5)
            mul $t2 $t2 1
            add $t9 $t9 $t2
            
            lb $t2 1($s5)
            mul $t2 $t2 2
            add $t9 $t9 $t2
            
            lb $t2 2($s5)
            mul $t2 $t2 2
            add $t9 $t9 $t2
        
        # Retour au point de depart pour l'image originale
            # Remonte d'une ligne
            li $t8 0
startLine1UpLoop:
    beq $t8 $s1 startLine1UpLoopPass
        subu $s5 $s5 1
        addi $t8 $t8 1
        j startLine1UpLoop
startLine1UpLoopPass:     
            # Remonte d'une ligne
            li $t8 0 
startLine2UpLoop:
    beq $t8 $s1 startLine2UpLoopPass
        subu $s5 $s5 1
        addi $t8 $t8 1
        j startLine2UpLoop  
startLine2UpLoopPass:
            # Incrementation du compteur colonne et de l'image orginale de 1
            addi $t3 $t3 1 
            addi $s5 $s5 1
            # Normalisation et seuillage des resultats 
            # Pour GX
            bltz $t6 valueAbsGX
                bge $t6 255 byte255GX
                    ble $t6 255 byteZeroGX
GY:         # Pour GY   
            bltz $t9 valueAbsGY
                bge $t9 255 byte255GY
                    ble $t9 255 byteZeroGY
            # Addition des matrices
addMatrix:         
            add $t6 $t6 $t9
            
            ble $t6 255 byteZeroGXGY
                j byte255GXGY
            
            beq $t6 255 byte255GXGY
                ble $t6 255 byteZeroGXGY
                    sb $t6 0($t0)
                    addi $t0 $t0 1
                    j startSobelFilterColumnLoop
                    
                    
# Fonction : GX            
valueAbsGX:
    negu $t6 $t6
    bge $t6 255 byte255GX
       ble $t6 255 byteZeroGX
          j GY
          
byte255GX:
    li $t6 255
    j GY
    
byteZeroGX:
    li $t6 0
    j GY

# Fonction : GY
valueAbsGY:
    negu $t9 $t9
    bge $t9 255 byte255GY
        ble $t9 255 byteZeroGY
            j addMatrix
            
byte255GY:
    li $t9 255
    j addMatrix
    
byteZeroGY:
    li $t9 0
    j addMatrix

# Fonction : GXGY
byte255GXGY:
    li $t6 255
    sb $t6 0($t0)
    addi $t0 $t0 1
    j startSobelFilterColumnLoop
    
byteZeroGXGY:
    li $t6 0
    sb $t6 0($t0)
    addi $t0 $t0 1
    j startSobelFilterColumnLoop
                  
startSobelFilterColumnLoopPass:
    li $t3 2 
    addi $t4 $t4 1
    j startSobelFilterLineLoop
# Pass
startSobelFilterLineLoopPass:
    # Epilogue
    lw $s6, 12($sp)
    lw $s5, 8($sp)
    lw $s1, 4($sp)
    lw $ra, 0($sp)
    addu $sp $sp, 16
    jr $ra

#///////////////////////////////////////////////////////////////////////////////////////////////////////////

# Fonction qui affiche un message d'erreur
ErrorFileMessage:
    la $a0, ERROR_MESSAGE # charge ERROR_MESSAGE in $a0
    jal printString       # jump and link printString
    
#///////////////////////////////////////////////////////////////////////////////////////////////////////////

# Fonction qui met fin au programme
Exit:
    li $v0, 10 # syscode -> 10 : exit program
    syscall
    
#///////////////////////////////////////////////////////////////////////////////////////////////////////////
