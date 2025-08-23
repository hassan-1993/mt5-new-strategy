#include <Arrays\ArrayInt.mqh>;
#include <Arrays\ArrayObj.mqh>;



struct Pair {
   double first;
   double second;
};


bool greenCandle(int index){
   return open(index)<close(index);
}



double bodyHeight(int index){
    return MathAbs(close(index)  - open(index));
}

bool greenCandles(int startIndex, int count){
   if(startIndex-count<0) return false;

   for(int i=startIndex; i>startIndex-count ;i--){
       if(!greenCandle(i)) return false;
   }
   return true;
}


double lowBody(int index){
  return MathMin(open(index), close(index)) ;
}


double highBody(int index){
  return MathMax(open(index), close(index));
}




double highTailHeight(int index){
 return high(index) - highBody(index);
}

double lowTailHeight(int index){
  return lowBody(index) - low(index);
}


double pipValue(){
  return 10 * SymbolInfoDouble (_Symbol, SYMBOL_TRADE_TICK_SIZE);
}


bool contains(int& list[], int value){
   int found = 0;
   for(int i=0; i<ArraySize(list); i++){
        if(list[i] == value) return true;
   }

   return false;
} 


double close(int index)
  {
   if(index<0){ 
      index = 0;
   }
   return iClose(Symbol(),Period(),index);
  }


double open(int index)
  {
   if(index<0){ 
      index = 0;
   }
   return iOpen(Symbol(),Period(),index);
  }

double high(int index)
  {
   if(index<0){ 
      index = 0;
   }
   return iHigh(Symbol(),Period(),index);
  }

double low(int index)
  {
   if(index<0){ 
      index = 0;
   }
   return iLow(Symbol(),Period(),index);
  }


double time(int index)
  {
   if(index<0){ 
      index = 0;
   }
   return iTime(Symbol(),Period(),index);
  }



double bidPrice(){
  return SymbolInfoDouble(_Symbol, SYMBOL_BID);
}

double askPrice(){
  return SymbolInfoDouble(_Symbol, SYMBOL_ASK);
}




//return highest candle between A and B
int maxHigh(int lowA, int lowB){
int a = MathMin(lowA, lowB);
int b = MathMax(lowA, lowB);
//a=1  b=5
return iHighest(Symbol(),Period(),MODE_HIGH,b-a+1,a);
}

int maxHighClose(int lowA, int lowB){
int a = MathMin(lowA, lowB);
int b = MathMax(lowA, lowB);
//a=1  b=5
return iHighest(Symbol(),Period(),MODE_CLOSE,b-a+1,a);
}



//return highest candle between A and B
int minLow(int lowA, int lowB){
int a = MathMin(lowA, lowB);
int b = MathMax(lowA, lowB);
//a=1  b=5
return iLowest(Symbol(),Period(),MODE_LOW,b-a+1,a);
}



int minLowClose(int lowA, int lowB){
  int a = MathMin(lowA, lowB);
  int b = MathMax(lowA, lowB);

  return iLowest(Symbol(),Period(),MODE_CLOSE,b-a+1,a);
}


bool areEqual(CArrayInt& a, CArrayInt& b){
   if(a.Total()!=b.Total()) return false;

   for(int i=0; i<a.Total(); i++){
         if(a.At(i)!= b.At(i)) return false;
   }
   return true;
}

int last(CArrayInt& array, int offset = 1){
   int total  = array.Total();
return array.At(array.Total()-offset);
}


int last(int& array[], int offset = 1){
return array[ArraySize(array)-offset];
}


CObject* last(CArrayObj &arr, int offset = 1){
     return arr.At(arr.Total()-offset);

}


string toString(CArrayInt* arr){
    string data = "";
    for(int i=0; i<arr.Total(); i++){
      data+= arr.At(i) + " ";
    } 
   return data;
}




double candle(ENUM_APPLIED_PRICE ptype, int index){

    switch(ptype){
       case PRICE_OPEN: return open(index);
       case PRICE_CLOSE: return close(index);
       case PRICE_HIGH: return high(index);
       case PRICE_LOW: return low(index);
   }

  return 0;
}