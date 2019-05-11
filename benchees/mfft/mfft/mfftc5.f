      SUBROUTINE MFFTC5(C,FAC)
*
*   PURPOSE:
*       ELEMENTARY COOLEY-TUKEY RADIX 5 STEP APPLIED TO A VECTOR-OF
*       VECTORS-OF-COMPLEX C[IVS,NV [IES,NE]].
*       SEE REF.[1] FOR NOTATIONS.
*       THIS ROUTINE CAN BE USED ONLY BY ROUTINE MFFTIV, WHICH CONTROLS
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
      COMPLEX T1,T2,T3,T4,T5,F1,F2,F3,F4
      REAL SIN72,RAD5D4,S36D72
      PARAMETER (
     $ SIN72 =  9.51056516295153572116439333E-1,
     $ RAD5D4 =  5.59016994374947424102293417E-1,
     $ S36D72 =  6.18033988749894848204586834E-1 )
*..  LAM > 0
          LAMF=MX
          DO 100 LAM=LSTEP,LLIM,LSTEP
            F1=FAC(LAMF)
            F2=FAC(2*LAMF)
            F3=FAC(3*LAMF)
            F4=FAC(4*LAMF)
            DO 90 MU=LAM,LAM+MLIM,MSTEP
              DO 80 I=MU,MU+ILIM,IES
                T1=C(I,1)*F1+C(I,4)*F4
                T2=C(I,2)*F2+C(I,3)*F3
                T3=(C(I,1)*F1-C(I,4)*F4)*SIN72
                T4=(C(I,2)*F2-C(I,3)*F3)*SIN72
                T5=T1+T2
                T1=RAD5D4*(T1-T2)
                T2=C(I,0)-0.25*T5
                C(I,0)=C(I,0)+T5
                T5=T2+T1
                T2=T2-T1
                T1=T3+S36D72*T4
                T3=S36D72*T3-T4
                C(I,1)=T5+CMPLX(-AIMAG(T1),REAL(T1))
                C(I,4)=T5-CMPLX(-AIMAG(T1),REAL(T1))
                C(I,2)=T2+CMPLX(-AIMAG(T3),REAL(T3))
                C(I,3)=T2-CMPLX(-AIMAG(T3),REAL(T3))
80            CONTINUE
90          CONTINUE
            LAMF=LAMF+MX
100       CONTINUE
 
*.. LAM=0
          DO 92 MU=0,MLIM,MSTEP
            DO 82 I=MU,MU+ILIM,IES
              T1=C(I,1)+C(I,4)
              T2=C(I,2)+C(I,3)
              T3=(C(I,1)-C(I,4))*SIN72
              T4=(C(I,2)-C(I,3))*SIN72
              T5=T1+T2
              T1=RAD5D4*(T1-T2)
              T2=C(I,0)-0.25*T5
              C(I,0)=C(I,0)+T5
              T5=T2+T1
              T2=T2-T1
              T1=T3+S36D72*T4
              T3=S36D72*T3-T4
              C(I,1)=T5+CMPLX(-AIMAG(T1),REAL(T1))
              C(I,4)=T5-CMPLX(-AIMAG(T1),REAL(T1))
              C(I,2)=T2+CMPLX(-AIMAG(T3),REAL(T3))
              C(I,3)=T2-CMPLX(-AIMAG(T3),REAL(T3))
82          CONTINUE
92        CONTINUE
      END
