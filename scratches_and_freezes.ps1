# YTP+++ PowerShell plugin: Scratches And Freezes
# PowerShell-native metadata prevents plugin discovery from parsing Lua syntax.

function Query {
    param($localeName, $localizationTokens)

    return @{
        name = 'Scratches And Freezes'
        description = 'Scratches And Freezes YTP+++ plugin.'
        settings = @(
            @{
                name = 'Display Name'
                value = 'effectName'
                type = 'label'
            },
            @{
                name = 'Description'
                value = 'description'
                type = 'label'
            },
            @{
                name = 'Chance Roll'
                value = '50'
                type = 'int'
                tooltip = 'Percentage chance for the effect to use a stronger damage pattern.'
            },
            @{
                name = 'Freeze Count'
                value = '3'
                type = 'int'
                tooltip = 'Number of freeze/stutter events to create.'
            },
            @{
                name = 'Freeze Duration'
                value = '0.20'
                type = 'float'
                tooltip = 'Approximate duration of each freeze in seconds.'
            },
            @{
                name = 'Scratch Intensity'
                value = '35'
                type = 'int'
                tooltip = 'Amount of simulated film scratches and noise.'
            },
            @{
                name = 'Heavy Damage'
                value = '0'
                type = 'bool'
                tooltip = 'Adds stronger noise, contrast, and chromatic damage.'
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
