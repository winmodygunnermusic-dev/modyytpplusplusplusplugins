# YTP+++ PowerShell plugin: Speed Ramp
# PowerShell-native metadata prevents plugin discovery from parsing Lua syntax.

function Query {
    param($localeName, $localizationTokens)

    return @{
        name = 'Speed Ramp'
        description = 'Gradually ramps video speed between slow and fast sections.'
        settings = @(
            @{
                name = 'Display Name'
                value = 'effectName'
                type = 'label'
            },
            @{
                name = 'Description'
                value = 'Gradually ramps video speed between slow and fast sections.'
                type = 'label'
            },
            @{
                name = 'Ramp Mode'
                value = '3'
                type = 'int'
                tooltip = '1=Slow-Fast, 2=Fast-Slow, 3=Slow-Fast-Slow, 4=Fast-Slow-Fast'
            },
            @{
                name = 'Slow Speed'
                value = '0.5'
                type = 'float'
                tooltip = 'Slowest playback speed. Recommended: 0.25 to 0.75.'
            },
            @{
                name = 'Fast Speed'
                value = '2.0'
                type = 'float'
                tooltip = 'Fastest playback speed. Recommended: 1.5 to 4.0.'
            },
            @{
                name = 'Ramp Strength'
                value = '100'
                type = 'int'
                tooltip = 'Overall strength of the speed-ramp effect from 0 to 100.'
            },
            @{
                name = 'Audio Pitch Compensation'
                value = '1'
                type = 'bool'
                tooltip = 'Attempts to preserve normal audio pitch while changing speed.'
            },
            @{
                name = 'Randomize Ramp'
                value = '0'
                type = 'bool'
                tooltip = 'Randomly chooses a ramp mode each time the effect runs.'
            }
        )
    }
}

function StartGeneration {
    param($options, $pluginSettings, $functions)
    return $true
}

function PostCommand {
    param($commandIndex, $outputResult, $errorResult, $options, $pluginSettings, $functions)
}

function StopGeneration {
    param($options, $pluginSettings, $functions)
    return $true
}
