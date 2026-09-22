# YTP+++ PowerShell plugin: Pitch Shift
# PowerShell-native metadata prevents plugin discovery from parsing Lua syntax.

function Query {
    param($localeName, $localizationTokens)

    return @{
        name = 'Pitch Shift'
        description = 'Shifts the pitch of the audio up or down.'
        settings = @(
            @{
                name = 'Display Name'
                value = 'effectName'
                type = 'label'
            },
            @{
                name = 'Description'
                value = 'Shifts the pitch of the audio up or down.'
                type = 'label'
            },
            @{
                name = 'Pitch Semitones'
                value = '5'
                type = 'float'
                tooltip = 'Pitch shift in semitones. Positive raises pitch, negative lowers it.'
            },
            @{
                name = 'Randomize'
                value = '0'
                type = 'bool'
                tooltip = 'Randomly selects a pitch shift within the selected range.'
            },
            @{
                name = 'Random Range'
                value = '8'
                type = 'float'
                tooltip = 'Maximum random pitch distance in semitones.'
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
