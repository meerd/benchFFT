      SUBROUTINE MFFTC9(C,FAC)
*
*   PURPOSE:
*       ELEMENTARY COOLEY-TUKEY RADIX 5 STEP APPLIED TO A VECTOR-OF
*       2-VECTORS-OF-COMPLEX C[IMS,NM [IVS,NV [IES,NE]]].
*       SEE REF.[1] FOR NOTATIONS.
*       THIS ROUTINE CAN BE USED ONLY BY ROUTINE MFFTIS, WHICH CONTROLS
*       ITS OPERATION THROUGH THE MFFTPA COMMON
*
*   DUMMY ARGUMENTS :
*
*   C   ARRAY BEING FOURIER  TRANSFORMED
*   FAC PHASE FACTORS, PREPARED BY MFFTP; NOT MODIFIED IN OUTPUT
*
      COMMON /MFFTPA/  IMS,IVS,IES,NM,NV,NE,MX,LX,MLIM,MSTEP,LLIM,LSTEP,
     $ NUSTEP,IVLIM,ILIM,MD2LIM,LD2LIM
      INTEGER NUSTEP
      COMPLEX C(0:NUSTEP-1,0:4),FAC(0:*)
      COMPLEX T1,T2,T3,T4,T5
      REAL SIN72,RAD5D4,S36D72
      PARAMETER (
     $ SIN72 =  9.51056516295153572116439333E-1,
     $ RAD5D4 =  5.59016994374947424102293417E-1,
     $ S36D72 =  6.18033988749894848204586834E-1 )
 
      IF(LX.NE.1)THEN
          DO 200 MU=0,MLIM,MSTEP
            DO 150 IV=MU,MU+IVLIM,IVS
              ILAMF=0
              ILAMF2=NUSTEP
              ILAMF3=2*NUSTEP
              ILAMF4=3*NUSTEP
              DO 100 ILAM=IV,IV+ILIM
                T1=C(ILAM,1)*FAC(ILAMF)+C(ILAM,4)*FAC(ILAMF4)
                T2=C(ILAM,2)*FAC(ILAMF2)+C(ILAM,3)*FAC(ILAMF3)
                T3=(C(ILAM,1)*FAC(ILAMF)-C(ILAM,4)*FAC(ILAMF4))*SIN72
                T4=(C(ILAM,2)*FAC(ILAMF2)-C(ILAM,3)*FAC(ILAMF3))*SIN72
                T5=T1+T2
                T1=RAD5D4*(T1-T2)
                T2=C(ILAM,0)-0.25*T5
                C(ILAM,0)=C(ILAM,0)+T5
                T5=T2+T1
                T2=T2-T1
                T1=T3+S36D72*T4
                T3=S36D72*T3-T4
                C(ILAM,1)=T5+CMPLX(-AIMAG(T1),REAL(T1))
                C(ILAM,4)=T5-CMPLX(-AIMAG(T1),REAL(T1))
                C(ILAM,2)=T2+CMPLX(-AIMAG(T3),REAL(T3))
                C(ILAM,3)=T2-CMPLX(-AIMAG(T3),REAL(T3))
                ILAMF=ILAMF+1
                ILAMF2=ILAMF2+1
                ILAMF3=ILAMF3+1
                ILAMF4=ILAMF4+1
100           CONTINUE
150         CONTINUE
200       CONTINUE
      ELSE
          DO 400 MU=0,MLIM,MSTEP
            DO 350 IV=MU,MU+IVLIM,IVS
              DO 300 ILAM=IV,IV+ILIM
                T1=C(ILAM,1)+C(ILAM,4)
                T2=C(ILAM,2)+C(ILAM,3)
                T3=(C(ILAM,1)-C(ILAM,4))*SIN72
                T4=(C(ILAM,2)-C(ILAM,3))*SIN72
                T5=T1+T2
                T1=RAD5D4*(T1-T2)
                T2=C(ILAM,0)-0.25*T5
                C(ILAM,0)=C(ILAM,0)+T5
                T5=T2+T1
                T2=T2-T1
                T1=T3+S36D72*T4
                T3=S36D72*T3-T4
                C(ILAM,1)=T5+CMPLX(-AIMAG(T1),REAL(T1))
                C(ILAM,4)=T5-CMPLX(-AIMAG(T1),REAL(T1))
                C(ILAM,2)=T2+CMPLX(-AIMAG(T3),REAL(T3))
                C(ILAM,3)=T2-CMPLX(-AIMAG(T3),REAL(T3))
300           CONTINUE
350         CONTINUE
400       CONTINUE
      ENDIF
      END
