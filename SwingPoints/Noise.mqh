#include "../Common/Utils.mqh"

class Noise{

  public: int fixedLows[];
  public: int fixedHighs[];

  public: void fix(int& lows[] , int& highs[]){
      /**
         Point 1: remove lows after each other 
         Point 2: remove highs after each other
      **/
      ArrayResize(fixedLows, ArraySize(lows));
      ArrayResize(fixedHighs, ArraySize(highs));

      int count = 0;
      for(int i=0;i<ArraySize(lows) ;i++){
          int nextHighIndex = getNextIndex(lows[i], highs);
          int selectedLow = lows[i];

          //if next high index is after the next low index => we have two lows after each other 
           while(i+1<ArraySize(lows) && nextHighIndex>=lows[i+1]){
                  //remove the higher lows
                  if(low(lows[i+1])<low(selectedLow)){
                     selectedLow =  lows[i+1];
                  }

                  i++;
            
          }    

          fixedLows[count] = selectedLow;
          count++;
      }

     ArrayResize(fixedLows, count);

     count = 0;
     for(int i=0;i<ArraySize(highs);i++){
          int nextLowIndex = getNextIndex(highs[i], lows);
          int selectedHigh = highs[i];

          //if next high index is after the next low index => we have two lows after each other 
           while(i+1<ArraySize(highs) && nextLowIndex>highs[i+1]){
                  //remove the higher lows
                  if(high(highs[i+1])>high(selectedHigh)){
                     selectedHigh =  highs[i+1];
                  }

                  i++;
            
          }    

          fixedHighs[count] = selectedHigh;
          count++;
      }

     ArrayResize(fixedHighs, count);
  }


  int getNextIndex(int value, int& compareArr[]){
     int foundIndex =  -1;
     for(int i=0;i<ArraySize(compareArr);i++){
         if(compareArr[i]>value){
             return compareArr[i];
         }
     }
     return foundIndex;
  }
};