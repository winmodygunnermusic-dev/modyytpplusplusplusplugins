# YTP+++ PowerShell plugin: Supercut
#
# This script uses PowerShell-native functions and hashtables so the plugin host
# can query its metadata without parsing Lua syntax.

function Query {
    param(
        $localeName,
        $localizationTokens
    )

    return @{
        name = 'Supercut'
        description = 'Rapidly cuts together many short sections of the source video.'
        settings = @(
            @{
                name = 'Display Name'
                value = 'Supercut'
                type = 'label'
            },
            @{
                name = 'Description'
                value = 'Rapidly cuts together many short sections of the source video.'
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
