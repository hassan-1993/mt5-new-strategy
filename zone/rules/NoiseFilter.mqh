//+------------------------------------------------------------------+
//|                                                  NoiseFilter.mqh |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "../../../common/Utils.mqh";
#include "../../../common/log/LogManager.mqh";
#include "../Zone.mqh";
#include "../ZoneUtils.mqh";

class NoiseFilter
  {

  private: int lowCloses[];
  private: int highCloses[];

   public: NoiseFilter(){
       //  ArrayCopy(this.lowCloses, lowCloses);
      //   ArrayCopy(this.highCloses, highCloses);
   }
   

    /**
         if price movement very small to next swing high or swing low with respect to some value -> considered as noise
    **/
    public: bool isFilterOut(Zone* zone){

        if(zone.Total()>0){ 
            int oldestTouchPoint = zone.getTouchPoint(0); 
          //  double move = findMoveReaction(zone.mainPrice(), zone.mainIndex(), oldestTouchPoint, zone.mode);
                  double move  = 1;
            //error_threshold
            if(move> 1) return false;
            
        }
        


     
        
        return true;
    }




  private: bool containAHighPointBetween(int fromCandle, int toCandle){
      return containPointBetween(store.highs, store.highCloses, fromCandle, toCandle);
  }

  private: bool containALowPointBetween(int fromCandle, int toCandle){
      return containPointBetween(store.lows, store.lowCloses, fromCandle, toCandle);
  }

   /**  
        check if a point exist between fromCandle and toCandle
   **/
   private: bool containPointBetween(CArrayInt& arr, CArrayInt& arrClose, int fromCandle, int toCandle){
      int temp = fromCandle;
      if(fromCandle<toCandle){
         fromCandle = toCandle;
         toCandle = temp;
      }
      
      for(int i = 0 ;i< arr.Total(); i++){
         if(fromCandle>arr[i] && toCandle< arr[i]){
               return true;
         }
      }

      for(int i = 0 ;i< arrClose.Total(); i++){
         if(fromCandle>arrClose[i] && toCandle< arrClose[i]){
               return true;
         }
      }

   return false;
   }


   /*
      cleaning duplicate touch points to avoid
      look for two low points not having any high between and remove one of them . same for high points
   */
   public: bool cleanDuplicateTouchPoints(Zone* zone){

      int mainIndex = zone.mainIndex();
      if(mainIndex == 161){
         int ok = 0;
      }
      string before = zone.fullInfo(); //
//      return true;
       for(int i=1 ; i<zone.Total(); i++){
            ZoneTouchInfo* touchInfoA = zone.getTouchInfo(i-1);
            ZoneTouchInfo* touchInfoB = zone.getTouchInfo(i);
      
            if(touchInfoA.mode == touchInfoB.mode){

               int ACandleIndex = touchInfoA.candleIndex();
               int BCandleIndex = touchInfoB.candleIndex();

             //  bool highBetween = touchInfoA.mode == MODE_LOW && containAHighPointBetween(touchInfoA.candleIndex(), touchInfoB.candleIndex());

               if(touchInfoA.mode == MODE_LOW && containAHighPointBetween(touchInfoA.candleIndex(), touchInfoB.candleIndex())){
                  continue;
               }

               if(touchInfoA.mode == MODE_HIGH && containALowPointBetween(touchInfoA.candleIndex(), touchInfoB.candleIndex())){
                  continue;
               }



               //must remove one of them -> keep the closest to the main Price  ( Exception case if comparing with main zone )
               double mainPrice = zone.mainPrice();   
               int AIndex = touchInfoA.candleIndex(); 
               int BIndex = touchInfoB.candleIndex();
               double price_distance_A = MathAbs(touchInfoA.price() - zone.mainPrice());
               double price_distance_B = MathAbs(touchInfoB.price() - zone.mainPrice());
               if(price_distance_A < price_distance_B){
                     //prefer A 
                     zone.Remove(i);
               }else{
                     //prefer B
                     zone.Remove(i-1);
               }
               i--;
               
            }
       }


      /* for(int i=0 ; i<zone.Total(); i++){
           ZoneTouchInfo* touchInfoA = zone.getTouchInfo(i);
      
           if(touchInfoA.mode == MODE_LOW && containAHighPointBetween(touchInfoA.candleIndex(), zone.mainCandleIndex)){
                  continue;
           }

           if(touchInfoA.mode == MODE_HIGH && containALowPointBetween(touchInfoA.candleIndex(), zone.mainCandleIndex)){
                  continue;
           }

           zone.Remove(i);
           i--;
       }*/

       return true;
    }

/*
""mainIndex = 161.0
 
  candle 210 mode:MODE_HIGH modeTypeClose
  candle 260 mode:MODE_HIGH modeTypeClose" (length: 103)
""mainIndex = 161.0
 
  candle 210 mode:MODE_HIGH modeTypeClose
  candle 260 mode:MODE_HIGH modeTypeClose
  candle 261 mode:MODE_HIGH modeType" (length: 140)
*/


 /*  public: double findMoveReaction(int touchPoint, double mainPrice){
         //find next low which is lower

         //assume we are checking closes low now
         bool isSwingLow = true;
         int finalLow = touchPoint;

         if(isSwingLow){

            //find next low which is lower then starting mainPrice of zone. 
            while(touchPoint>=0){   
               int candleIndex = this.lowCloses[finalLow];
               if(open(this.lowCloses[candleIndex])  < mainPrice){
                     break;
               }
               finalLow--;
            }


            int candleIndex = -1;
            if(finalLow == touchPoint){   
                  //no lower low after it -> take low 0
                  finalLow = 0;
                  candleIndex = maxHighClose(this.lowCloses[touchPoint], 0);;
            }else{
                  candleIndex = maxHighClose(this.lowCloses[touchPoint], this.lowCloses[finalLow]);
            }
  
           
            double move = close(candleIndex) - mainPrice;

            if(move<0){
               addLog("negative value " + move + " in findMoveReaction");
               ExpertRemove();
            }

            return move;
           
   
        }

    
        addLog("invalid code");
        ExpertRemove();
       
        return -1;
   }*/


    



  }