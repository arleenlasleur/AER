class AerAm_shard extends Ammo;

function bool HandlePickupQuery(inventory Item){
   local aerwpn w;
   local pawn p;
   if(owner == none) return false;
   p = pawn(owner);
   if(p == none) return false;
   w = aerwpn(p.findinventorytype(class'aerwpn'));
   if(w == none) return false;
   if((class == item.class) || (ClassIsChildOf(item.class, class'Ammo') && (class == Ammo(item).parentammo))){
      if (w.ammo_chg>=w.ammo_max) return true;
      w.ammo_chg += w.ammo_clip;
      if(w.ammo_chg > w.ammo_max) w.ammo_chg = w.ammo_max;
      item.PlaySound(item.PickupSound);
      item.SetRespawn();
      return true;
   }
   if(Inventory == None) return false;
   return Inventory.HandlePickupQuery(Item);
}

function postbeginplay(){  setPhysics(PHYS_Falling);  }
function landed(vector hitnor){  setPhysics(PHYS_None);  }

defaultproperties{
        MaxAmmo=1
        UsedInWeaponSlot(1)=1
        PickupViewMesh=LodMesh'UnrealShare.TarydiumPickup'
        PickupSound=Sound'UnrealShare.Pickups.AmmoSnd'
        Icon=Texture'UnrealShare.Icons.I_StingerAmmo'
        PickupMessage=""
        CollisionRadius=22.0
        CollisionHeight=6.0
        Mesh=LodMesh'UnrealShare.TarydiumPickup'
        bCollideActors=True
}
