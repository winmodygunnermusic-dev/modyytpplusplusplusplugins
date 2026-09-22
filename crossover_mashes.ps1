# YTP+++ PowerShell plugin: Crossover Mashes
#
# This script uses PowerShell-native functions and hashtables so the plugin host
# can query its metadata without parsing Lua syntax.

function Query {
    param(
        $localeName,
        $localizationTokens
    )

    return @{
        name = 'Crossover Mashes'
        description = 'Cuts between crossover sections with random speed, reverse, stutter, zoom and glitch processing.'
        settings = @(
            @{
                name = 'Display Name'
                value = 'Crossover Mashes'
                type = 'label'
            },
            @{
                name = 'Description'
                value = 'Cuts between crossover sections with random speed, reverse, stutter, zoom and glitch processing.'
                type = 'label'
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
