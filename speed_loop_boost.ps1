# YTP+++ PowerShell plugin: Speed Loop Boost
# PowerShell-native metadata prevents plugin discovery from parsing Lua syntax.

function Query {
    param($localeName, $localizationTokens)

    return @{
        name = 'Speed Loop Boost'
        description = 'Speed Loop Boost YTP+++ plugin.'
        settings = @(
            @{
                name = 'Display Name'
                value = 'EFFECT_NAME'
                type = 'label'
            },
            @{
                name = 'Description'
                value = 'EFFECT_DESCRIPTION'
                type = 'label'
            },
            @{
                name = 'Loop Count'
                value = '4'
                type = 'int'
                tooltip = 'Number of times the boosted loop is repeated.'
            },
            @{
                name = 'Loop Duration'
                value = '0.60'
                type = 'float'
                tooltip = 'Length of the loop section in seconds.'
            },
            @{
                name = 'Starting Speed'
                value = '1.00'
                type = 'float'
                tooltip = 'Playback speed of the first loop.'
            },
            @{
                name = 'Boost Multiplier'
                value = '1.50'
                type = 'float'
                tooltip = 'Speed multiplier applied to each successive loop.'
            },
            @{
                name = 'Maximum Speed'
                value = '8.00'
                type = 'float'
                tooltip = 'Maximum playback speed allowed for a loop.'
            },
            @{
                name = 'Randomize Boost'
                value = '1'
                type = 'bool'
                tooltip = 'Adds small random variations to each loop speed.'
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
