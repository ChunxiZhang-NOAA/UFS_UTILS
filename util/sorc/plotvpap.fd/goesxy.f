      SUBROUTINE GOESXY(WLONG0,DISSAT,SCALE,ALAT,WLONG,X,Y,IEXIT)
C$$$  SUBPROGRAM DOCUMENTATION BLOCK
C                .      .    .                                       .
C SUBPROGRAM:    GOESXY      GOES I/J FROM LAT/LONG
C   PRGMMR: SHIMOMURA        ORG: W/NP12     DATE: 1997-01-07
C
C ABSTRACT: THE (X,Y)-COORDINATES ON A PSEUDO-SATELLITE IMAGE IS
C   COMPUTED FROM A GIVEN LATITUDE/LONGITUDE.  IT IS ASSUMED THAT
C   THE SATELITE IS TRULY GEOSTATIONARY OVER THE EQUATOR.
C
C PROGRAM HISTORY LOG:
C   YY-MM-DD  ORIGINAL AUTHOR: DAVID SHIMOMURA
C   89-04-18  STEVE LILLY  UPDATE DOCUMENTATION BLOCK
C   93-05-06  LILLY CONVERT SUBROUTINE TO FORTRAN 77
C   97-01-07  SHIMOMURA - CONVERT TO RUN ON CRAY
C
C USAGE:    CALL GOESXY  (WLONG0,DISSAT,SCALE,ALAT,WLONG,X,Y,IEXIT)
C
C   INPUT ARGUMENT LIST:
C     WLONG0   - THE MERIDIAN OF THE SUBSATELLITE POINT IN DEGREES WEST.
C     DISSAT   - THE DISTANCE FROM THE EARTH'S CENTER TO THE SATELLITE.
C              - DISSAT IS EXPRESSED IN UNITS OF EARTH RADII.  THE
C              - EARTH RADIUS IS ASSUMED TO BE 6371.2 KM.
C     SCALE    - THE MAP REDUCTION SCALE IN MILLIONS.  (SCALE = 25 IS
C              - FOR A 1:25M MAP.)
C     ALAT     - LATITUDE OF THE GIVEN POINT IN DEGREES.  (NEGATIVE FOR
C              - SOUTHERN HEMISPHERE.)
C     WLONG    - LONGITUDE OF THE POINT IN DEGREES WEST.
C
C   OUTPUT ARGUMENT LIST:
C     X        - THE X-COORDINATE ON THE MAP, IN INCHES, FROM THE CENTER
C     Y        - THE Y-COORDINATE ON THE MAP, IN INCHES, FROM THE
C                EQUATOR.
C     IEXIT    - = 0 FOR NORMAL RETURN.
C                = 1 IF POINT WON'T SHOW ON MAP.
C                = 2 IF GIVEN AN OUT-OF-RANGE ARGUMENT.
C
C REMARKS:
C
C ATTRIBUTES:
C   LANGUAGE: FORTRAN 77
C   MACHINE:  CRAY
C
C$$$
C
      REAL   CNVINM
      DATA   CNVINM      / 39.37 /
C     ...CNVINM CONVERTS METERS TO INCHES.
      REAL   CNVRD
      DATA   CNVRD       / 0.0174533 /
C     ...CNVRD CONVERTS DEGREES TO RADIANS.
      REAL   DISMIN
      DATA   DISMIN     / 2.0 /
C     ...GROSS LOWER LIMIT TEST ON GIVEN DISSAT.
      REAL   REKM3
      DATA   REKM3      / 6.3712 /
C     ...THE RADIUS OF THE EARTH IN THOUSANDS OF KM.
C
      IEXIT = 0
      X = 0.0
      Y = 0.0
      R = REKM3 * CNVINM / SCALE
      DSRAT = DISSAT
      IF(DSRAT .LE. DISMIN) GO TO 900
      DS = DSRAT * REKM3 * CNVINM / SCALE
      XXLIM0 = R * R / DS
      ALATR = ALAT * CNVRD
C
C     ... IF THE VISIBLE HEMISPHERE INCLUDES THE GREENWICH MERIDIAN, 
C     ... SINCE THE LONGITUDE IS IN DEGREES WEST WE MUST ACCOUNT FOR THE
C     ... DISCONTINUITY THERE.
C
      ALONG = WLONG
      IF(WLONG0 .GT. 270.0) GO TO 100
      IF(WLONG0 .LT.  90.0) GO TO 200
      GO TO 300
C
  100 CONTINUE
      IF(ALONG .GT. (WLONG0 - 270.0)) GO TO 300
      ALONG = 360.0 + ALONG
      GO TO 300
  200 CONTINUE
      IF(ALONG .LT. (WLONG0 + 270.0)) GO TO 300
      ALONG = ALONG - 360.0
      GO TO 300
C
  300 CONTINUE
      DLONG = WLONG0 - ALONG
      IF(ABS(DLONG) .LE. 90.0) GO TO 400
C     ...OR ELSE THIS POINT IS IN THE INVISIBLE HEMISPHERE.
      GO TO 911

  400 CONTINUE
      DLONGR = DLONG * CNVRD
      XX = R * COS(ALATR) * COS(DLONGR)
      IF(XX .LT. XXLIM0) GO TO 911
      YY = R * COS(ALATR) * SIN(DLONGR)
      ZZ = R * SIN(ALATR)
C
C     ... NOW (XX,YY,ZZ) IS THE TRUE POSITION ON THE EARTH'S SURFACE, 
C     ... GIVEN ONLY THAT THE EARTH IS A TRUE SPHERE.
C
C     ... WHERE IS (XX,YY,ZZ) PROJECTED ON THE IMAGE PLANE, 
C     ... THAT IMAGE PLANE BEING THE PLANE PASSING THROUGH THE CENTER 
C     ... OF THE EARTH AND WHICH IS ORTHOGONAL TO THE LINE JOINING THE 
C     ... CENTER OF THE EARTH AND THE SATELLITE?
C
      C1 = DS / (DS - XX)
      ZPRIME = C1 * ZZ
      YPRIME = C1 * YY
      Y = ZPRIME
      X = YPRIME
      GO TO 999
C
  900 CONTINUE
C     ... COME HERE IF THE GIVEN DISSAT WAS OUT-OF-RANGE.
      IEXIT = 2
      GO TO 999
C
  911 CONTINUE
C     ... COME HERE IF THE POINT IS HIDDEN FROM THE VISIBLE FACE.
      IEXIT = 1
      GO TO 999
C
  999 CONTINUE
      RETURN
      END
