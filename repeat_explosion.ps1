# YTP+++ PowerShell plugin: Repeat Explosion
# PowerShell-native metadata prevents plugin discovery from parsing Lua syntax.

function Query {
    param($localeName, $localizationTokens)

    return @{
        name = 'Repeat Explosion'
        description = 'Repeatedly punches and repeats short video segments with explosive impact.'
        settings = @(
            @{
                name = 'Display Name'
                value = 'Repeat Explosion'
                type = 'label'
            },
            @{
                name = 'Description'
                value = 'Repeatedly punches and repeats short video segments with explosive impact.'
                type = 'label'
            },
            @{
                name = 'Explosion Count'
                value = '4'
                type = 'int'
                tooltip = 'Number of repeated explosion hits.'
            },
            @{
                name = 'Explosion Duration'
                value = '0.18'
                type = 'float'
                tooltip = 'Approximate duration of each repeated hit in seconds.'
            },
            @{
                name = 'Intensity'
                value = '75'
                type = 'int'
                tooltip = 'Controls how strongly the repeated hits are emphasized.'
            },
            @{
                name = 'Randomize'
                value = '1'
                type = 'bool'
                tooltip = 'Randomizes the timing of each explosion hit.'
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
