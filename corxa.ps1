# Function to check if the type is already loaded in the current AppDomain
function Is-TypeLoaded($typeName) {
    $types = [AppDomain]::CurrentDomain.GetAssemblies() | ForEach-Object { $_.GetTypes() }
    return $types.Name -contains $typeName
}

# Check if the MouseMover type is already loaded
if (-not (Is-TypeLoaded "MouseMover")) {
    Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class MouseMover {
    [DllImport("user32.dll")]
    public static extern bool SetCursorPos(int x, int y);
}
"@
}

# Check if the KeyPressDetector type is already loaded
if (-not (Is-TypeLoaded "KeyPressDetector")) {
    Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class KeyPressDetector {
    [DllImport("user32.dll")]
    public static extern short GetAsyncKeyState(int vKey);
}
"@
}

# Load the Windows.Forms assembly for mouse position functionality
Add-Type -AssemblyName "System.Windows.Forms"

# Define the Esc key code
$escKeyCode = 0x1B

Write-Host "Script running in the background. Press 'Esc' to exit."

# Loop to move the mouse, simulate keyboard input, and check for the Esc key press
while ($true) {
    # Check if the 'Esc' key is pressed globally
    if ([KeyPressDetector]::GetAsyncKeyState($escKeyCode) -ne 0) {
        Write-Host "Esc key pressed. Exiting script..."
        break
    }

    # Get the current mouse position
    $currentPos = [System.Windows.Forms.Cursor]::Position

    # Move the mouse by 1px diagonally (frequent mouse movement)
    [MouseMover]::SetCursorPos($currentPos.X + 1, $currentPos.Y + 1)
    Start-Sleep -Milliseconds 100  # Move the mouse more frequently

    # Move the mouse back to the original position
    [MouseMover]::SetCursorPos($currentPos.X, $currentPos.Y)
    Start-Sleep -Milliseconds 100

    # Simulate keyboard input (e.g., pressing the 'Shift' key every 5 seconds)
    if ((Get-Date).Second % 5 -eq 0) {
        Add-Type -TypeDefinition @"
        using System;
        using System.Runtime.InteropServices;

        public class KeyboardSimulator {
            [DllImport("user32.dll", CharSet = CharSet.Auto)]
            public static extern uint keybd_event(byte bVk, byte bScan, uint dwFlags, uint dwExtraInfo);
        }
"@
        [KeyboardSimulator]::keybd_event(0x10, 0, 0, 0)  # Simulate SHIFT key press
        [KeyboardSimulator]::keybd_event(0x10, 0, 2, 0)  # Simulate SHIFT key release
    }
}
