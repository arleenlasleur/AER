class AerGr_afterglow extends Effects;

function postbeginplay(){
   settimer(0.03,false);
}
function timer(){
   if(LightBrightness>3){
      LightBrightness-=3;
   }else{
      LightBrightness=0;
      destroy();
   }
   settimer(0.03,true);
}

defaultproperties{
        LifeSpan=4.5
        RemoteRole=ROLE_None
        DrawType=DT_None
        AmbientGlow=0
        LightEffect=LE_NonIncidence
        LightType=LT_Steady
        LightBrightness=0
        LightHue=170
        LightSaturation=195
        LightRadius=4
}
