// =============================================
// THL-target messages internet download manager
// Usage: set Hint="AERIDM" to make message
//        downloadable upon playerpawn touch
// Single-user only. No replication.
// Messages length is autodetected.
// Supports random compression ratio, set in TDS
// =============================================
class AerWk_IDM extends Trigger;
var translatorevent msg_targ;
var byte modem_rssi;
var byte unzip_stage;
var int payload_tot;
var int payload_done;
var aerwpn w;

function do_payload_setup(){
   local string tmp_s;
   local byte i;
   if(msg_targ == none) return;
   if(payload_done >= payload_tot*10) goto done_progress;

   tmp_s = string(payload_done);
   if(tmp_s == "0") tmp_s = "00";    // prevent empty var
   msg_targ.message = "AERIDM " $ left(tmp_s,len(tmp_s)-1) // trunc last x10 because of no decimal dot there
                                $ ";;;"  // data marker
                                $ string(payload_tot);
   do_display_update();
   return;
   done_progress:
   settimer(0.25,true);
   if(unzip_stage >= 10) goto done_unzip;
   unzip_stage++;
   msg_targ.message = "Decompressing";
   for(i=0;i<unzip_stage;i++) msg_targ.message $= ".";
   do_display_update();
   return;
   done_unzip:
   msg_targ.message = self.message;
   do_display_update();
   disable('timer');
}

function do_display_update(){
   if(w != none && w.ena_translator) w.query_trans_msg_data();
}

function touch(actor other){
   local pawn p;
   if(!IsRelevant(other)) return;
   p = pawn(other);
   if(p == none) return;
   w = aerwpn(p.findinventorytype(class'aerwpn'));   // network replication flaw: w = only last touched pawn's w
   if(w != none) modem_rssi = w.modem_rssi;          // any new playerpawns owning aerwpn and touching, will overwrite w
   settimer(1.0,true);
   setcollision(false);
}

function timer(){
   local int add_done;
   if(w != none) modem_rssi = w.modem_rssi;   // will anyway dl on last known speed
              add_done = 26; // was 26
   switch(modem_rssi){
      case 1: add_done = 43; break;   // this shitcode is just faster
      case 2: add_done = 58; break;   // than another string parse
      case 3: add_done = 70; break;
      case 4: add_done = 79; break;
      case 5: add_done = 88; break;
      case 6: add_done = 95; break;
   }
   payload_done += add_done;
//   broadcastmessage(string(payload_done));
   do_payload_setup();
}

defaultproperties{
  TriggerType=TT_PlayerProximity
  payload_tot=1
  payload_done=0
  unzip_stage=0
  CollisionRadius=40.0
  CollisionHeight=40.0
  Message=""
}
