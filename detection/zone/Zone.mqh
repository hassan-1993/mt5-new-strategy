//+------------------------------------------------------------------+
//|                                                         Zone.mqh |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Arrays\ArrayObj.mqh>
#include <Arrays\ArrayInt.mqh>;
#include <Arrays\ArrayString.mqh>;
#include "../../common/Utils.mqh";
#include "ZoneStore.mqh";


class ZoneTouchInfo: public CObject{

   public: int mode;
   public: int modeType;
   public: int storeIndex;
   public: int candle_index;


   public: ZoneTouchInfo(int mode, int modeType, int candleIndex){
      this.mode = mode;
      this.modeType = modeType;
      this.candle_index = candleIndex;
   }
   

   public: int candleIndex(){
      return candle_index;
   }

   public: double price(){
      if(modeType == MODE_CLOSE){
          return close(candle_index);
     }else if(mode == MODE_HIGH){
         return high(candle_index);
     }else if(mode == MODE_LOW){
         return low(candle_index);
     }
     
     return -1;
   }

   
};


class Zone:public CObject{


  public: CArrayObj touchInfos; //order must be from past till present
  public: double mainCandleIndex;
  public: ENUM_SERIES_INFO_INTEGER mode; //if representing high or low
  public: ENUM_SERIES_INFO_INTEGER modeType; // if representing close candles
  private: CArrayString debugTouchPoints; 
  public: double     min_price;
  public: double     max_price;

  public: Zone(int mode, int modeType, int candleIndex){
         ZoneTouchInfo* info = new ZoneTouchInfo(mode, modeType, candleIndex);
         this.min_price = info.price();
         this.max_price = info.price();
         touchInfos.Add(info);
   }


  public: double Gap(Zone &other){
     double new_min = MathMin(min_price, other.min_price);
     double new_max = MathMax(max_price, other.max_price);
     return new_max - new_min;
  }
  
  public: bool CanMerge(Zone &other, double threshold)
   {
      double distance = Gap(other);
      return (distance <= threshold);
   }
   
   
   void MergeFrom(Zone &other)
   {
      bool canMerge = CanMerge(other, 0.1);
      for(int i=0; i<other.touchInfos.Total(); ++i){
          ZoneTouchInfo* otherPoint = other.touchInfos.At(i);
          touchInfos.Add(new ZoneTouchInfo(otherPoint.mode, otherPoint.modeType, otherPoint.candle_index));
      }
         
      min_price = MathMin(min_price, other.min_price);
      max_price = MathMax(max_price, other.max_price);
   }
   
   
  public: bool Remove(int index){
      if(!touchInfos.Delete(index)){
         addLog("failed to remove a touch Point from Zone");
         ExpertRemove();
      }
      debugTouchPoints.Delete(index);
      return true;
  }
  public: double mainPrice(){
    return (max_price + min_price)/2;
  }
  

  public: bool containTouchPoint(int candleIndex , int mode, int modeType){   
       for(int i=0; i<touchInfos.Total(); i++){
         ZoneTouchInfo* info = touchInfos.At(i);
         if(info.candleIndex() == candleIndex && info.mode == mode && info.modeType == modeType){
               return true;
         }
      }
   return false;
  }
  public: void addTouchPoint(int index, int mode, int modeType){
      // touchPoints.Add(index);
       touchInfos.Add(new ZoneTouchInfo(mode, modeType, index));

       debugTouchPoints.Add( " candle " + store.candleIndex(index , mode, modeType) + " mode:" + modeInfo(mode) + " modeType" + modeTypeInfo(modeType));

     //  debugTouchPoints[touchInfos.Total()-1] = " candle " + store.candleIndex(index , mode, modeType) + " mode:" + modeInfo(mode) + " modeType" + modeTypeInfo(modeType);
  }

  public: string debugInfo(){
      string debug;
      debug+="minPrice: " + min_price + " max_price: " + max_price;
      for(int i=0 ;i< touchInfos.Total(); i++){
            int mode = getTouchInfo(i).mode;
            int modeType = getTouchInfo(i).modeType;
            debug += "\n " + " candle " + getTouchInfo(i).candleIndex() + " mode:" + modeInfo(mode) + " modeType" + modeTypeInfo(modeType) + " price: " + getTouchInfo(i).price();
      }
      return debug;
  }


  public: string fullInfo(){
     string debug = "mainIndex = " + mainCandleIndex;
     debug+= "\n " + debugInfo();
     return debug;
  }

  public: string shortInfo(int maxIndex = -1){
       

       string debug = "m" + mainCandleIndex;;
       for(int i=0 ;i< touchInfos.Total() && ( maxIndex == -1 || i <= maxIndex); i++){
            int mode = getTouchInfo(i).mode;
            int modeType = getTouchInfo(i).modeType;
            debug += " " + " c" + getTouchInfo(i).candleIndex();
      }
      return debug;
  }


  private: string modeInfo(int mode){
     if(mode == MODE_LOW){
         return "MODE_LOW";   
      }else if(mode == MODE_HIGH){
         return "MODE_HIGH";
      }

   return "Undefined";
  }

  private: string modeTypeInfo(int modeType){
      if(modeType == MODE_CLOSE) return "Close";
      else return "";
  }
 
  public: int getTouchPoint(int index){
      if(index >= touchInfos.Total() || index < 0){  
         return -1;
      }
       return getTouchInfo(index).storeIndex;
  }

  public: ZoneTouchInfo* getTouchInfo(int index){
      return this.touchInfos.At(index);
   }

  public: int Total(){
     return this.touchInfos.Total();
  }

  public: int mainIndex(){
    return this.mainCandleIndex;
  }


  public: void sort(){
    bool sortAgain = true;
 
    string _fullInfo = fullInfo();
    
    while(sortAgain){
         sortAgain = false;
        
         for(int j=0; j < Total()- 1; j++){
             int totalCount = Total();
            ZoneTouchInfo* info1 = getTouchInfo(j);
            ZoneTouchInfo* info2 = getTouchInfo(j+1);
            ZoneTouchInfo* tempInfo1 = new ZoneTouchInfo(info1.mode,info1.modeType, info1.candleIndex()); //to avoid invalid pointers
            ZoneTouchInfo* tempInfo2 = new ZoneTouchInfo(info2.mode,info2.modeType, info2.candleIndex()); //to avoid invalid pointers

            string info1Str = debugTouchPoints.At(j);
            string info2Str = debugTouchPoints.At(j+1);

            if(info1.candleIndex() > info2.candleIndex()){
                touchInfos.Update(j, tempInfo2);
                touchInfos.Update(j+1, tempInfo1); 

                debugTouchPoints.Update(j,info2Str);
                debugTouchPoints.Update(j+1, info1Str);
                sortAgain = true; 
            }
         }
    }

   string debugging = "";
   for(int i=0; i<Total(); i++){
         
         debugging+= " " + getTouchInfo(i).candleIndex() + " mode: " + getTouchInfo(i).mode + " type " + getTouchInfo(i).modeType;
   }
}

}; 






