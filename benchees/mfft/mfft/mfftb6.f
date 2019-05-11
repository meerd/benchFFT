      SUBROUTINE MFFTB6(C,FAC)
*
*   PURPOSE:
*       ELEMENTARY GENTLEMAN-SANDE RADIX 3 STEP APPLIED TO A VECTOR-OF
*       2-VECTORS-OF-COMPLEX C[IMS,NM [IVS,NV [IES,NE]]].
*       SEE REF.[1] FOR NOTATIONS.
*       THIS ROUTINE CAN BE USED ONLY BY ROUTINE MFFTDM, WHICH CONTROLS
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
      COMPLEX C(0:NUSTEP-1,0:2),FAC(0:*)
      COMPLEX T0,T1,T2,F1,F2
      REAL SIN60
      PARAMETER ( SIN60 =  8.6602540378443864E-1)
 
 
*..  MU > 0
            MUF=LX
            DO 200 MU=MSTEP,MLIM,MSTEP
              F1=CONJG(FAC(MUF))
              F2=CONJG(FAC(MUF*2))
              DO 190 LAM=MU,MU+LLIM,LSTEP
                DO 180 IV=LAM,LAM+IVLIM,IVS
                DO 180 I=IV,IV+ILIM,IES
                  T0=C(I,1)+C(I,2)
                  T2=(C(I,1)-C(I,2))*SIN60
                  T1=C(I,0)-0.5*T0
                  C(I,0)=C(I,0)+T0
                  C(I,1)=(T1-CMPLX(-AIMAG(T2),REAL(T2)))*F1
                  C(I,2)=(T1+CMPLX(-AIMAG(T2),REAL(T2)))*F2
  180           CONTINUE
  190         CONTINUE
              MUF=MUF+LX
200         CONTINUE
            DO 193 LAM=0,LLIM,LSTEP
              DO 183 IV=LAM,LAM+IVLIM,IVS
              DO 183 I=IV,IV+ILIM,IES
                T0=C(I,1)+C(I,2)
                T2=(C(I,1)-C(I,2))*SIN60
                T1=C(I,0)-0.5*T0
                C(I,0)=C(I,0)+T0
                C(I,1)=(T1-CMPLX(-AIMAG(T2),REAL(T2)))
                C(I,2)=(T1+CMPLX(-AIMAG(T2),REAL(T2)))
183           CONTINUE
193         CONTINUE
      END
