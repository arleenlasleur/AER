class AerAm_native extends Ammo;
        // plshelpme: in some conditions (upak intermission nad such), main ammo consume persists, even though NOWHERE in
        //            code used. the weapon MAY lock in noammo state because of this. I want weapon continue be bringed up
        //            with empty secondary ammo

defaultproperties{
        AmmoAmount=9999
        MaxAmmo=9999
        UsedInWeaponSlot(1)=1
        PickupMessage=""
}
