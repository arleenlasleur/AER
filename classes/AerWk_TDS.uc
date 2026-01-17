// =============================================
// TDS, translator dummy silicon, used for:
// - translatorevent.trans handle interception
// - translatorevents initial prepare in level
// - override activatetranslator() callback
//
// This translator do not parse message EOLs, so
// for AER screen their layout must be set manually
// Use ..\design\unr2txt.html to convert texts
// =============================================
class AerWk_TDS extends Translator;
var aerwpn w;
var AerWk_THL TList;
var bool pending_nosave;

function TravelPreAccept(){ if(Pawn(Owner).FindInventoryType(class) == None) Super.TravelPreAccept(); }
simulated function PrevHistory(){ if(TList.Prev != none) Tlist = Tlist.Prev; }
simulated function NextHistory(){ if(TList.Next != none) Tlist = Tlist.Next; }
simulated function DrawTranslator(canvas c){}

function postbeginplay(){
   local translatorevent t;
   local AerWk_IDM idm;
   local float payload_tot,payload_mod;
   local bool tmp_bool;
   foreach allactors(class'translatorevent',t){
      t.m_newmessage = "";
      t.m_transmessage = "";
      t.newmessagesound = none;

      tmp_bool = (instr(caps(t.hint),"AERIDM") != -1);

//      tmp_bool = caps(t.hint) ~= "AERIDM";
      if(!tmp_bool) continue;
      idm = spawn(class'AerWk_IDM',,,t.location);
      if(idm == none) continue;
      idm.SetCollisionSize(t.collisionradius * 1.2, t.collisionheight * 1.2);
      idm.msg_targ = t;
      idm.message = t.message;
      payload_tot = float(len(t.message));
      if(instr(caps(t.hint),"AERIDM OVPS ") != -1)               // override msg length, uncompressed
         payload_tot = float(right(t.hint,len(t.hint) - 12));
      t.hint = "";
      payload_mod = frand();
      payload_mod = lerp(payload_mod, 0.43, 0.59);   // random "gzip" the message
      payload_tot *= payload_mod;
      idm.payload_tot  = int(payload_tot);
      idm.payload_done = 0;
      idm.do_payload_setup();
   }
   setlocation(vect(32767,32767,32767));
}

function activatetranslator(bool bHint){
   if(w==none) return;
   if(w.trans_msg_areasign) return;
   w.ena_translator = !w.ena_translator;
   if(w.ena_translator){
      w.ena_areamap = false;
      w.transmsg_applied_scroll = 0;  // reset message scrolling if any
      w.query_trans_msg_data();
   }
   bNewMessage = false;
}

function forget_nosave(){
   if(!pending_nosave) return;
   while(TList.Prev != none) PrevHistory();  // find first queue member
   while(TList.Next != none){                // process all
      if(caps(TList.msg_targ.hint) == "AERNOSAVE") TList.remove();
      NextHistory();
   }
   pending_nosave = false;
}

simulated function SetMessage(translatorevent tma){
  if(Tlist == none){
    Tlist = Spawn (class'AerWk_THL',owner);
    Tlist.msg_targ = tma;
  }else
    Tlist = TList.Process(tma);
  if(caps(tma.hint) == "AERNOSAVE") pending_nosave = true;
}

simulated function translatorevent GetMessage(){
  if (Tlist != none) return TList.msg_targ;
  return none;
}

// function bool handlepickupquery(inventory inv){  return true;  }  // todo check for aertranslator there, this hangs other pickups
// todo move this to aerwpn

state Activated{              // prohibit accidental state changes
Begin:
   gotostate('deactivated');
}

state Deactivated{
Begin:
   if(w != none) w.ena_translator = false;
}

defaultproperties{
   pending_nosave=false
   bDisplayableInv=false
   bActivatable=false
   bNewMessage=False
   bNotNewMessage=False
}
