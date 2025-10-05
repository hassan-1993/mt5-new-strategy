#include "Noise.mqh"

int C_OFFSET_BY = 1;  //For example C_OFFSET_EVERY = 96, every 96 candles we offset findLowsHighs by C_OFFSET_BY
int C_OFFSET_EVERY = 48;

/**
   move: refers either to MODE_LOW or MODE_HIGH . to retrieve the lowest or highest candle price
   moveType: refers to whether to use MODE_CLOSE
**/
int getmove(int move, int count, int endPos, int moveType = -1)
  {
   if(move!=MODE_HIGH && move!=MODE_LOW && (moveType!=-1 || moveType!=MODE_CLOSE))
      return (-1);
   int currentBar=endPos;
   int moveReturned=getNextMove(move,count*2+1,currentBar-count, moveType);
   
   while(moveReturned!=currentBar)
     {
      currentBar=getNextMove(move,count,currentBar+1, moveType);
      moveReturned=getNextMove(move,count*2+1,currentBar-count, moveType);
     }
   return(currentBar);
  }


int getNextMove(int move, int count, int endPos, int moveType = -1)
  {
   if(endPos<0)
     {
      count +=endPos;
      endPos =0;
     }


   if(moveType == MODE_CLOSE){
     return((move==MODE_HIGH)?
          iHighest(Symbol(),Period(),MODE_CLOSE,count,endPos):
          iLowest(Symbol(),Period(),MODE_CLOSE,count,endPos));
   }else{
      return((move==MODE_HIGH)?
          iHighest(Symbol(),Period(),(ENUM_SERIESMODE)move,count,endPos):
          iLowest(Symbol(),Period(),(ENUM_SERIESMODE)move,count,endPos));
   }
   
}
  
  
  
void getHighs(int& arr[], int count, int distance = 5, int start_pos = -1, int end_pos = 0, int modeType  = -1){
    
    if(start_pos >0 ){
         //fix it later 
         ArrayResize(arr,5000);
    }else{
         ArrayResize(arr,count);
    }

    int high = end_pos-1; 
    for(int i=0;i<count  || start_pos>0;i++){
        high = getmove(MODE_HIGH,distance,high+1, modeType);
        if(start_pos>0 && high>start_pos){
            ArrayResize(arr,i);
            break;
        }
        arr[i] = high;
   }
}


/**

  enable_timeframes: if enabled while moving back in history the period_move increase
**/
void getLows(int& arr[], int count,int distance, int start_pos = -1, int end_pos = 0, bool enable_timeframes = true, int modeType = -1){
    if(start_pos >0 ){
            //fix it later 
            ArrayResize(arr,5000);
    }else{
          ArrayResize(arr,count);
     }

    int low = end_pos-1;
    for(int i=0;i<count || start_pos>0;i++){
        int period_move = 0;

         if(enable_timeframes){
            period_move = getDistance(distance, low, end_pos);
         }else {
            period_move = distance;
         }
       // int distance = getDistance(distance, low, end_pos);
      //  Print("distance is " + distance + " last low" + low);
        low = getmove(MODE_LOW,period_move,low+1,modeType);
        if(start_pos>0 && low>start_pos){
            ArrayResize(arr,i);
            break;
        }
        arr[i] = low;
         
   }
}




int getDistance(float mainDistance, float low, int end_pos){
   float lastLow = low - end_pos;
   //every 100 candles offset distance by 1
   float offset = (lastLow/C_OFFSET_EVERY) * C_OFFSET_BY;
   return (int) offset + mainDistance;
}



void findLowsHighs(int start ,  int end, int distance,   int count, int& lows[], int& highs[], bool enable_timeframes = true){
    int all_highs[];
    int all_lows[];
    getHighs(all_highs,count , distance, start, end);
    getLows(all_lows, count, distance, start, end, enable_timeframes);
    
    Noise noise();
    noise.fix(all_lows, all_highs);  
    ArrayCopy(lows, noise.fixedLows);
    ArrayCopy(highs, noise.fixedHighs);
} 