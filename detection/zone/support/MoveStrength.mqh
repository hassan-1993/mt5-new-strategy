

/*
Goal

find movement reaction for each point   -> until the next touch point or broken

**/


#include "../ZoneStore.mqh";
#include "../Zone.mqh";
#include "../../../common/log/LogManager.mqh";



class MoveStrength {

 /*find the first candle that closes below or closes above above either buy zone or sell zone respectively   */
 private: static int findTo(Zone* obj, bool isMainPoint,  ZoneTouchInfo* touchInfo = NULL){
     
     int from =  touchInfo.candleIndex();
     int currentMode = touchInfo.mode ;

     int firstHigh = -1;

         firstHigh = 0;

         if(firstHigh == -1){
            return 0;
          }else{
         /**
             find either first 
             1 - the first touch point in zone after the high  
             2-  the first close that touches below (must be a close only since we identify zones only by closes)
          **/
            
            for(int i = store.sortedPoints.Total()-1 ; i>=0; i--){
                  TouchPoint *point = store.sortedPoints.At(i);
                  if(point.candleIndex< from && point.mode == currentMode){
                      if(obj.containTouchPoint(point.candleIndex, point.mode, point.modeType)){
                              //to found
                              return point.candleIndex;
                      }
               
                   //  if(point.mode == MODE_LOW){   
                               /*we check the close price only (//TODO maybe check the open price also)
                                 if the tail was below the zone but closes above zone than that is ignored (the reason because currently only closes price are considered as potential zones)
                               */
                               double toPrice = close(point.candleIndex);
                               double fromPrice = touchInfo.price();
                               if(point.mode == currentMode &&  point.mode == MODE_LOW && toPrice < fromPrice){   
                                    return point.candleIndex;
                               }else if(point.mode == currentMode && point.mode == MODE_HIGH && toPrice > fromPrice){  
                                     return point.candleIndex;
                              }
                   //  }
                   
                  }
            }
         }

   //   }
      
      return 0;
  };


public: static double findTouchPointMove(Zone* obj, int index){
    ZoneTouchInfo *info = obj.getTouchInfo(index);
    int to = findTo(obj, false, info);
    findTo(obj, false, info);
    double move = findMoveReaction(obj, info, to, info.mode);
    return move;
}

/**
  find zone main point full movement strength 
**/
public: static double findFullZone(Zone* obj){
   int nextClose = findNextBrokenClose(obj, true, NULL);
   
   //double move = findMoveReaction(obj, obj.mainCandleIndex, nextClose, obj.mode);
   return 0;
};

/*find the next close candle that breaks the zone ( the reason why not low or a high candle because zones currently only created by closes candles) */
static int findNextBrokenClose(Zone* obj, bool isMainPoint,  ZoneTouchInfo* touchInfo = NULL){
     int currentMode = isMainPoint? obj.mode: touchInfo.mode ;
     int from = isMainPoint? obj.mainCandleIndex: touchInfo.candleIndex();

     for(int i = store.sortedPoints.Total()-1 ; i>=0; i--){
        TouchPoint *point = store.sortedPoints.At(i);
        if(point.candleIndex< from && point.mode == currentMode){
            double toPrice = close(point.candleIndex);
            double fromPrice = isMainPoint? obj.mainPrice(): touchInfo.price();

            if(point.modeType == MODE_CLOSE){
                if(point.mode == MODE_LOW && toPrice < fromPrice){   
                           return point.candleIndex;
                   }else if(point.mode == MODE_HIGH && toPrice > fromPrice){  
                          return point.candleIndex;
                }
            }
        }
     }

   return 0;
  }



static int findBeforeBrokenClose(Zone* obj, bool isMainPoint,  ZoneTouchInfo* touchInfo = NULL){
     int currentMode = isMainPoint? obj.mode: touchInfo.mode ;
     int from = isMainPoint? obj.mainCandleIndex: touchInfo.candleIndex();

     for(int i = 0 ; i<store.sortedPoints.Total(); i++){
        TouchPoint *point = store.sortedPoints.At(i);
        if(point.candleIndex> from && point.mode == currentMode){
            double toPrice = close(point.candleIndex);
            double fromPrice = isMainPoint? obj.mainPrice(): close(touchInfo.candle_index);

         //   if(point.modeType == MODE_CLOSE){
                if(point.mode == MODE_LOW && toPrice < fromPrice){   
                           return point.candleIndex;
                   }else if(point.mode == MODE_HIGH && toPrice > fromPrice){  
                          return point.candleIndex;
                }
           // }
        }
     }

   return -1;
  }






 public: static double findMoveReaction(Zone* obj, ZoneTouchInfo& point, int toCandle, int mode){
   double mainPrice = obj.mainPrice();

   
   int fromCandleTouchPoint = point.candleIndex();
   
   if(fromCandleTouchPoint<467 && fromCandleTouchPoint>465){
      int ok = 0;
   }

   if(mode == MODE_HIGH){
            int maxLow = minLow(fromCandleTouchPoint, toCandle);     
            double touchPrice = point.price();       
            double moveReaction = touchPrice - low(maxLow);
            return moveReaction; 
   }else{
           int maxHigh = maxHigh(fromCandleTouchPoint, toCandle);
           //if fromCandle is higher than the main price of zone. then movement reaction will start from FromCandle
           double touchPrice = point.price();
           double moveReaction = high(maxHigh) - touchPrice;
           return moveReaction;
   }

};

};

