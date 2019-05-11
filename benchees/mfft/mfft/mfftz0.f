         SUBROUTINE MFFTZ0(W1,ISE1,NE,W2,ISE2)
**** PURPOSE : VECTOR COPY ROUTINE
*    PARAMETERS :
*        W1 : VECTOR TO BE COPIED
*        ISE1: STRIDE OF W1
*        NE : NUMBER OF ELEMENTS
*        W2 : DESTINATION VECTOR
*        ISE2: STRIDE OF W2
         INTEGER W1(0:*),W2(0:*)
         J=0
         DO 1 I=0,(NE-1)*ISE1,ISE1
         W2(J)=W1(I)
         J=J+ISE2
1        CONTINUE
         END
 
 
