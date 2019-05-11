      SUBROUTINE MFFTB8(C,FAC)
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
      COMPLEX C(0:NUSTEP-1,0:1),FAC(0:*)
      COMPLEX T0,T1,T2,F1,F2
      REAL SIN60
      PARAMETER ( SIN60 =  8.6602540378443864E-1)
 
 
      IF(MX.NE.1)THEN
            DO 200 LAM=0,LLIM,LSTEP
              DO 190 IV=LAM,LAM+IVLIM,IVS
                IMUF=0
                DO 180 IMU=IV,IV+ILIM
 
                  T0=C(IMU,1)+C(IMU,2)
                  T2=(C(IMU,1)-C(IMU,2))*SIN60
                  T1=C(IMU,0)-0.5*T0
                  C(IMU,0)=C(IMU,0)+T0
                  C(IMU,1)=(T1-CMPLX(-AIMAG(T2),REAL(T2)))*FAC(IMUF)
                  C(IMU,2)=(T1+CMPLX(-AIMAG(T2),REAL(T2)))*FAC(IMUF+
     $                     NUSTEP)
                  IMUF=IMUF+1
  180           CONTINUE
  190         CONTINUE
200         CONTINUE
        ELSE
            DO 400 LAM=0,LLIM,LSTEP
              DO 390 IV=LAM,LAM+IVLIM,IVS
                DO 380 IMU=IV,IV+ILIM
                  T0=C(IMU,1)+C(IMU,2)
                  T2=(C(IMU,1)-C(IMU,2))*SIN60
                  T1=C(IMU,0)-0.5*T0
                  C(IMU,0)=C(IMU,0)+T0
                  C(IMU,1)=(T1-CMPLX(-AIMAG(T2),REAL(T2)))
                  C(IMU,2)=(T1+CMPLX(-AIMAG(T2),REAL(T2)))
380             CONTINUE
390           CONTINUE
400         CONTINUE
        ENDIF
      END
