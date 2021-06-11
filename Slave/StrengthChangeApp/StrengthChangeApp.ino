// 大きさを次第に変えることによって、ファントムセンセーションを起こすためのプログラム
// バージョン1.0 Motor_and_Motor_Vibrationを参考に1つだけの場合を作ってみた．
// バージョン2.0 位置が変化しない振動を提示できるようにする

#include <Arduino_JSON.h>
#define NAIL 10
#define FINGER 9
#define WRIST 6
#define MAXSTRENGTH 255
#define MINSTRENGTH 102
#define ZEROSTRENGTH 0
#define DEBUG false
#define RUNUPDURATION 100

const int DefaultIncreasePin = WRIST;
const int DefaultDecreasePin = FINGER;
const int DefaultVibrationDurationMs = 500;
const int DefaultPin1 = WRIST;
const int DefaultPin1VibrationStrength = MAXSTRENGTH;
const int DefaultPin2 = FINGER;
const int DefaultPin2VibrationStrength = MAXSTRENGTH;

/*

受け取る値は
大きくなるピン番号，小さくなるピン番号，大きくなる時間
で，1セット．

実際に渡す値は，
[
  {
    "IncreasingPin": "制御するピン（次第に増加する）",
    "DecreasingPin": "制御するピン（次第に減少する）",
    "VibrationDurationMs": "振動を提示する時間（Ms）"
  },
  {
  ...
  }
]
テスト用の値
[{"IncreasingPin": "10","DecreasingPin": "6","VibrationDurationMs": "2000"}]

**追加**
受け取る値に
制御ピン1，制御ピン1における振動の大きさ，制御ピン2，制御ピン2における振動の大きさ，振動を提示する時間
で，1セットを追加．

実際に渡す値は，
[
  {
    "Pin1": "制御ピン1",
    "Pin1VibrationStrength":"制御ピン1における振動の大きさ",
    "Pin2": "制御ピン2",
    "Pin2VibrationStrength":"制御ピン2における振動の大きさ",
    "VibrationDurationMs": "振動を提示する時間（Ms）"
  },
  {
  ...
  }
]
テスト用の値
[{"Pin1": "9","Pin1VibrationStrength":"255","Pin2": "10","Pin2VibrationStrength":"255","VibrationDurationMs": "2000"}]
*/

const String IncreasePinKey = "IncreasingPin";
const String DecreasePinKey = "DecreasingPin";
const String VibrationDurationMsKey = "VibrationDurationMs";
const String Pin1Key = "Pin1";
const String Pin1VibrationStrengthKey = "Pin1VibrationStrength";
const String Pin2Key = "Pin2";
const String Pin2VibrationStrengthKey = "Pin2VibrationStrength";

int IncreasePin = DefaultIncreasePin;
int DecreasePin = DefaultDecreasePin;
int VibrationDurationMs = DefaultVibrationDurationMs;
int Pin1 = DefaultPin1;
int Pin1VibrationStrength = DefaultPin1VibrationStrength;
int Pin2 = DefaultPin2;
int Pin2VibrationStrength = DefaultPin2VibrationStrength;

/*分割する区間数*/
const int SectionNumAll = 4;
int SectionNum = 0;

/*振動に関する変数*/
unsigned long start_vibration_time_ms = 0;
bool FirstIncreaseFlag = false;
int FirstVibrationDurationMs = 100;
bool isMoving = false;

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  pinMode(NAIL, OUTPUT);
  pinMode(FINGER, OUTPUT);
  pinMode(WRIST, OUTPUT);
}

void DebugPrint(const String c){
  // DEBUGフラッグがtrueの時だけ表示する
  if (DEBUG){
    Serial.print(c);    
  }
}

void DebugPrintln(const String c){
  // DEBUGフラッグがtrueの時だけ表示する
  if (DEBUG){
    Serial.print(c);    
    Serial.print("\n");
  }
}

int GetJSONParameter(JSONVar parameter, const String key, const int default_value){
  if(parameter.hasOwnProperty(key)){
      String p_string = (const char*)parameter[key];
      DebugPrintln(p_string);
      return p_string.toInt();
  }else{
    DebugPrintln("None");
      return default_value;
  }
}


int CalVibrationStrength(bool is_increase){
  if(is_increase){
    /*振動の強さを増加する方の強さ計算（時間ごとに変化？）*/
    return (MAXSTRENGTH - MINSTRENGTH) / SectionNumAll * SectionNum + MINSTRENGTH;
  }else{
    /*振動の強さを減少する方の強さ計算（時間ごとに変化？）*/
    return MAXSTRENGTH - (MAXSTRENGTH - MINSTRENGTH) / SectionNumAll * SectionNum;
  }
}

bool isVibrate(){
  if(start_vibration_time_ms != 0){
    return 
      (/*now time*/millis() - start_vibration_time_ms) < VibrationDurationMs;    
  }
  return false;
}

void setMoveFlag(JSONVar parameter){
  isMoving = parameter.hasOwnProperty(IncreasePinKey);
}

bool isMove(){
  return isMoving;
}

void Init(bool isStart){
  analogWrite(IncreasePin, ZEROSTRENGTH);
  analogWrite(DecreasePin, ZEROSTRENGTH);
  SectionNum = 0;
  FirstIncreaseFlag = true;
  if(isStart){
    start_vibration_time_ms = millis();
  }else{
    Serial.println("Vibration end");
    start_vibration_time_ms = 0;
  }
}

void loop() {
  String input;
  
  if(Serial.available()>0){
    input = Serial.readStringUntil('\n');
    DebugPrintln(input);
    JSONVar vibration_parameters = JSON.parse(input);

    JSONVar parameter = vibration_parameters[0];
    DebugPrintln(JSON.stringify(parameter));
    setMoveFlag(parameter);

    Serial.println("Vibration parameter is " + JSON.stringify(parameter));

    if(isMove()){
      IncreasePin = GetJSONParameter(
                        /*parameter*/parameter,
                        /*key*/IncreasePinKey,
                        /*default_value*/DefaultIncreasePin
                        );
      DecreasePin = GetJSONParameter(
                        /*parameter*/parameter,
                        /*key*/DecreasePinKey,
                        /*default_value*/DefaultDecreasePin
                        );
      VibrationDurationMs = GetJSONParameter(
                        /*parameter*/parameter,
                        /*key*/VibrationDurationMsKey,
                        /*default_value*/DefaultVibrationDurationMs
                        );      
    }else{
      Pin1 = GetJSONParameter(
                        /*parameter*/parameter,
                        /*key*/Pin1Key,
                        /*default_value*/DefaultPin1
                        );
      Pin1VibrationStrength = GetJSONParameter(
                        /*parameter*/parameter,
                        /*key*/Pin1VibrationStrengthKey,
                        /*default_value*/DefaultPin1VibrationStrength
                        );
      Pin2 = GetJSONParameter(
                        /*parameter*/parameter,
                        /*key*/Pin2Key,
                        /*default_value*/DefaultPin2
                        );
      Pin2VibrationStrength = GetJSONParameter(
                        /*parameter*/parameter,
                        /*key*/Pin2VibrationStrengthKey,
                        /*default_value*/DefaultPin2VibrationStrength
                        );
      VibrationDurationMs = GetJSONParameter(
                        /*parameter*/parameter,
                        /*key*/VibrationDurationMsKey,
                        /*default_value*/DefaultVibrationDurationMs
                        );
    }
    Init(/*isStart*/true);
  }
  
  if(isVibrate()){
    SectionNum += 1;
    if(FirstIncreaseFlag){
      if(isMove()){
        analogWrite(IncreasePin, MAXSTRENGTH);
        analogWrite(DecreasePin, MAXSTRENGTH);
      }else{
        analogWrite(Pin1, MAXSTRENGTH);
        analogWrite(Pin2, MAXSTRENGTH);
      }
      delay(FirstVibrationDurationMs);
      FirstIncreaseFlag = false;
    }
    if(isMove()){
      analogWrite(IncreasePin, CalVibrationStrength(true));
      analogWrite(DecreasePin, CalVibrationStrength(false));
    }else{
      analogWrite(Pin1, Pin1VibrationStrength);
      analogWrite(Pin2, Pin2VibrationStrength);
    }
    delay((VibrationDurationMs - FirstVibrationDurationMs)/SectionNumAll);
    if(SectionNum == SectionNumAll){
      Init(/*isStart*/false);
    }
  }else{
    analogWrite(Pin1, ZEROSTRENGTH);
    analogWrite(Pin2, ZEROSTRENGTH);
  }
}
