## Command Protocol Documentation 

# Command Protocol

## Overview
The RC Controller app communicates with ESP32/ESP8266 using structured string commands.

## Command Format

### Movement Commands
```
MOVE:UP={0|1},DOWN={0|1},LEFT={0|1},RIGHT={0|1},SPEED={0-100},BOOST={0|1}
```

Examples:
- Forward: `MOVE:UP=1,DOWN=0,LEFT=0,RIGHT=0,SPEED=50,BOOST=0`
- Turn Right: `MOVE:UP=0,DOWN=0,LEFT=0,RIGHT=1,SPEED=30,BOOST=0`
- Forward Left with Boost: `MOVE:UP=1,DOWN=0,LEFT=1,RIGHT=0,SPEED=75,BOOST=1`

### Accessory Commands
- Lights On: `LIGHT:1`
- Lights Off: `LIGHT:0`
- Horn: `HORN:1`
- Emergency Stop: `STOP:1`

## Communication Protocols

### BLE (ESP32)
- Service UUID: `12345678-1234-1234-1234-1234567890ab`
- Characteristic UUID: `87654321-4321-4321-4321-ba0987654321`
- Commands sent as string via BLE characteristic write

### WiFi (ESP8266)
- HTTP POST to `/command`
- Parameter: `cmd` with command string
- Example: `POST /command` with body `cmd=MOVE:UP=1,DOWN=0,LEFT=0,RIGHT=0,SPEED=50,BOOST=0`

## Response Handling
- ESP devices process commands and provide serial debug output
- No response required for normal operation
- Status available via `/status` endpoint for WiFi
