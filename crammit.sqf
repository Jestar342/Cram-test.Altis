
_this spawn {
    params ["_crams", "_center", "_alarms", "_range"];
    private ["_targs", "_explo", "_getTargets", "_soundSources", "_assignedTargs"];

    [west, "Base"] sideChat "INCOMING: Activating C-RAM!";

    _soundSources = [];
    [_alarms,_soundSources] spawn {
        params ["_alarms", "_soundSources"];
        {
            private _source = createSoundSource ["Sound_Alarm2", _x, [], 0];
            uisleep (random 3);
            _soundSources pushBack _source;
        } forEach _alarms;
    };

    _assignedTargs = [];
    _getTargets = {
        ((_center nearObjects ["MissileCore", _range]) +
        (_center nearObjects ["RocketCore", _range]) +
        (_center nearObjects ["ShellCore", _range]))
    };

    _targs = [];
    while {
        _targs = [] call _getTargets;
        count _targs > 0;
    }
    do {
        {
            private _targ = _x;
            private _targId = str _targ;

            private _availableCrams = _crams select { not (_x getVariable ["CRAM_IN_USE", false]) };
            if (count _availableCrams < 1) exitWith {uisleep 0.01};

            if (_targId in _assignedTargs) exitWith {};
            _assignedTargs pushBack _targId;

            private _cram = _availableCrams select 0;
            _cram setVariable ["CRAM_IN_USE", true];

            [_targ, _cram] spawn {
                params ["_targ", "_cram"];
                private "_explo";

                _cram setVehicleAmmo 1;
                _cram doWatch _targ;
                _alt = ((getPosATL _targ) select 2);

                uisleep 3;
                _start = diag_tickTime;

                while {diag_tickTime < _start + 3}
                do {
                    if (_alt > 50) then {
                        [_cram, ""] call BIS_fnc_fire;
                        if (diag_tickTime > _start + 2.5) then {
                            _explo = "DemoCharge_Remote_Ammo" createVehicle position _targ;
                            deleteVehicle _targ;
                            _explo setDamage 1;
                        };
                    };
                    uisleep 0.01;
                };
                _cram doWatch objNull;
                _cram setVariable ["CRAM_IN_USE", false];
            };

        } forEach _targs;
    };

    _assignedTargs = [];

    _soundSources spawn {
        uisleep 10;
        [WEST, "Base"] sideChat "NO TARGET: Deactivating C-RAM.";
        uisleep 1;
        { deleteVehicle _x; uisleep 0.5; } forEach _this;
    };

};
