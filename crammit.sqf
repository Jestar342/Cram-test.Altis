
_this spawn {
    params ["_crams", "_center", "_alarms", "_range"];
    private ["_targs", "_explo", "_getTargets", "_soundSources"];

    [west, "Base"] sideChat "INCOMING: Activating C-RAM!";

    _soundSources = [];
    {
      private _source = createSoundSource ["Sound_Alarm2", _x, [], 0];
      _soundSources pushBack _source;
    } forEach _alarms;

    _targs = [];
    while {
        _targs = _center nearObjects ["ShellCore", _range];
        count _targs > 0;
    }
    do {
        private _availableCrams = _crams select { not (_x getVariable ["CRAM_IN_USE", false]) };
        if (count _availableCrams > 0) then {
            {
                [selectRandom _targs, _x] spawn {
                    params ["_targ", "_cram"];
                    private "_explo";
                    _cram setVariable ["CRAM_IN_USE", true];
                    _cram setVehicleAmmo 1;
                    _cram doWatch _targ;
                    uisleep 1;
                    _start = diag_tickTime;
                    while {diag_tickTime < _start + 3}
                    do {
                        if (((getPosATL _targ) select 2) > 50) then {
                            [_cram, ""] call BIS_fnc_fire;
                            uisleep 0.001;
                        };
                    };
                    _cram doWatch objNull;
                    _cram setVariable ["CRAM_IN_USE", false];
                    _explo = "DemoCharge_Remote_Ammo" createVehicle position _targ;
                    deleteVehicle _targ;
                    _explo setDamage 1;
                };
            } forEach _availableCrams;
        };
    };

    { deleteVehicle _x } forEach _soundSources;

    [WEST, "Base"] sideChat "NO TARGET: Deactivating C-RAM.";
};
