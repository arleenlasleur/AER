class AerAm_core extends Ammo;  // restocks main energy, slow consumed 100-0%. if 0 then aer shuts off until 10%. regen faster in energetic places (warm, electro, on sunlight)

/*  todo:
  1. accept ammo from killed enemies and use it as core.
   - autospawn on weapondrop (how? spawnnotify wont work, these arent spawned, they change state)
   - spawn linked invisible ammo pickup which stay only for weapon (inherit lifespan)
   - reduce to remain ammo (inherit PickupAmmoCount, e.g. PAmmo defaults 60, from killed may be 64)
   - PAmmo is 5% of AER batt, ASMD/Shock = 10%.

  2. (mbshit )Maybe if not picked up, ammo transfer wirelessly, bc AER power management may suck energy.

  3. autoexec needhide if playerstarts found in xxx radius. (travelpostaccept hack)
*/

function bool HandlePickupQuery(inventory Item){
   local aerwpn w;
   local pawn p;
   if(owner == none) return false;
   p = pawn(owner);
   if(p == none) return false;
   w = aerwpn(p.findinventorytype(class'aerwpn'));
   if(w == none) return false; // was true, NFI
   if((class == item.class) || (ClassIsChildOf(item.class, class'Ammo') && (class == Ammo(item).parentammo))){
      if(w.power_chg >= w.power_max && w.batt_chg >= w.batt_full) return true; // todo add become inventory if full recharge. 5 cores max
      w.power_chg = w.power_max;
      w.batt_chg += w.batt_clip;
      if(w.batt_chg > w.batt_full) w.batt_chg = w.batt_full;
      item.PlaySound(item.PickupSound);
      item.SetRespawn();
      return true;
   }
   if(Inventory == None) return false;
   return Inventory.HandlePickupQuery(Item);
}

function postbeginplay(){  setPhysics(PHYS_Falling);  }
function landed(vector hitnor){  setPhysics(PHYS_None);  }

/*  // plshelpme: once entered travelled level, within playerstarts observing both presence of core/shard actor.
    //            this confuses player. these actors (possible) are the give_slave_items()-borne (without them ammo
    //            pickup works incorrect - the very first picked up ammo doesn't make effect, only second one).
    //            tried following code: (it doesn't do what it supposed. or my decides on ammo actors origin are wrong)
    //            same shit happens on AerAM_shard class.

event TravelPostAccept(){ 
   local pawn p;
   local playerstart ps;
   local bool needhide;
   super.travelpostaccept();
   p = pawn(owner);
   if(p == none) return;          // maybe this is where link breaks. owner may absent.
   needhide = false;
   foreach radiusactors(class'playerstart',ps,128,p.location) needhide = true;
   if(needhide) setlocation(vect(65535,65535,65535));
} */

defaultproperties{
        MaxAmmo=1
        UsedInWeaponSlot(1)=1
        PickupViewMesh=LodMesh'UnrealShare.AsmdAmmoM'
        PickupSound=Sound'UnrealShare.Pickups.AmmoSnd'
        Icon=Texture'UnrealShare.Icons.I_ASMD'
        PickupMessage=""
        CollisionRadius=10.0
        CollisionHeight=20.0
        Mesh=LodMesh'UnrealShare.AsmdAmmoM'
        bCollideActors=True
}
