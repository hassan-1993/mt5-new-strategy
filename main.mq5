
#include "./strategy/TestZones.mqh"
#include "./common/drawobjs/DrawIdGenerator.mqh"


datetime preBarTime = NULL;

void OnTick(void){

    datetime lastBarTime = iTime(_Symbol, PERIOD_CURRENT, 0);
 
    

    if(!isNewBar()) return;

       Print(lastBarTime);

    testing();
    int total = ObjectsTotal(0, -1, -1);
    total = total;
    Print("total is " + total );
    onDrawEnd();
}



bool isNewBar(){
    if(preBarTime == NULL || preBarTime!= iTime(_Symbol, PERIOD_CURRENT, 0)){
        preBarTime = iTime(_Symbol, PERIOD_CURRENT, 0);
        return true;
    }

   return false;
}



int OnInit(void){
   return INIT_SUCCEEDED;
}