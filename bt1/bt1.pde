#include <AFMotor.h>
#include <Servo.h> 

#define THROTTLE_SIGNAL_IN 1 // INTERRUPT 0 = DIGITAL PIN 2 - use the interrupt number in attachInterrupt
#define THROTTLE_SIGNAL_IN_PIN 3 // INTERRUPT 0 = DIGITAL PIN 2 - use the PIN number in digitalRead

#define NEUTRAL_THROTTLE 1476 // this is the duration in microseconds of neutral throttle on an electric RC Car

#define RUDDER_SIGNAL_IN 0 // INTERRUPT 0 = DIGITAL PIN 2 - use the interrupt number in attachInterrupt
#define RUDDER_SIGNAL_IN_PIN 2 // INTERRUPT 0 = DIGITAL PIN 2 - use the PIN number in digitalRead

#define NEUTRAL_RUDDER 1476 // this is the duration in microseconds of neutral throttle on an electric RC Car
#define MAX_THROTTLE 1892
#define MIN_THROTTLE 1060

#define RUDDER_LEFT 1060
#define RUDDER_RIGHT 1892

volatile int nThrottleIn = NEUTRAL_THROTTLE;
volatile int nRudderIn = NEUTRAL_RUDDER;

volatile unsigned long ulStartPeriod = 0; 
volatile boolean bNewThrottleSignal = false;
volatile boolean bNewRudderSignal = false; 
unsigned long ulLastServoControlInput = 0;
unsigned long ulLastServoCommand = 0;


float nLeftSpeed = 0;
float nRightSpeed = 0;
int nBearing = 0;

AF_DCMotor LeftMotor(1);
AF_DCMotor RightMotor(2);

void setup()
{
  myservo.attach(9);
  attachInterrupt(THROTTLE_SIGNAL_IN,calcTInput,CHANGE);
  attachInterrupt(RUDDER_SIGNAL_IN,calcRInput,CHANGE);
  Serial.begin(9600);
}

void loop()
{
  int nServoPos = 0;
  int nServoDelta = 1;
  if(bNewThrottleSignal || bNewRudderSignal)
 {
   nBearing = (nRudderIn - NEUTRAL_RUDDER)/4.2;
   nRightSpeed = nLeftSpeed = (nThrottleIn - NEUTRAL_THROTTLE)/4.2;
   if ( nBearing < -5 )  {
     nLeftSpeed = int((nLeftSpeed / 100) * (100 - abs(nBearing)));
   } 
   if ( nBearing > 5 ) {
     nRightSpeed = int((nRightSpeed / 100 ) * (100 - abs(nBearing)));
   }
   Serial.print("Left:");
   Serial.print(nLeftSpeed);
   Serial.print(" Right:");
   Serial.println(nRightSpeed);
   bNewThrottleSignal = bNewRudderSignal = false;
 }

  // set speed and direction
  LeftMotor.setSpeed(abs(nLeftSpeed));
  RightMotor.setSpeed(abs(nRightSpeed));
  
  if ( nRightSpeed > 0 )  {
     RightMotor.run(FORWARD);
  } else if ( nRightSpeed < 0 )  {
    RightMotor.run(BACKWARD);
  } else {
    RightMotor.run(RELEASE);
  }
  if ( nLeftSpeed > 0 )  {
     LeftMotor.run(FORWARD);
  } else if ( nLeftSpeed < 0 )  {
    LeftMotor.run(BACKWARD);
  } else {
    LeftMotor.run(RELEASE);
  }
 
  // sweep servo 
  nServoPos += nServoDelta;
  if ( nServoPos = 180 ) {
    nServoDelta = -1
  }
  if ( nServoPos = 0 )  {
    nServoDelta = 1;
  }
  // add in a check for the last servo command input also, say > 10sec
  ulLastServoCommand = micros();
  if ( ulLastServoCommand > 15000 )  {
    myservo.write(pos); 
    ulLastServoCommand = 0;
  }
  
 // other processing ...
}

void calcTInput()
{
  if(digitalRead(THROTTLE_SIGNAL_IN_PIN) == HIGH)
  {
    ulStartPeriod = micros();
  }
  else
  {
    if(ulStartPeriod && (bNewThrottleSignal == false))
    {
      nThrottleIn = (int)(micros() - ulStartPeriod);
      ulStartPeriod = 0;
      bNewThrottleSignal = true;
    }
  }
}

void calcRInput()
{
  if(digitalRead(RUDDER_SIGNAL_IN_PIN) == HIGH)
  {
    ulStartPeriod = micros();
  }
  else
  {
    if(ulStartPeriod && (bNewRudderSignal == false))
    {
      nRudderIn = (int)(micros() - ulStartPeriod);
      ulStartPeriod = 0;
     bNewRudderSignal = true;
    }
  }
}

