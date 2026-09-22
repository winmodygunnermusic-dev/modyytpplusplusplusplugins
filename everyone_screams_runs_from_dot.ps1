# YTP+++ PowerShell plugin: Everyone Screams Runs From Dot
#
# This script uses PowerShell-native functions and hashtables so the plugin host
# can query its metadata without parsing Lua syntax.

function Query {
    param(
        $localeName,
        $localizationTokens
    )

    return @{
        name = 'Everyone Screams Runs From Dot'
        description = 'Everyone Screams Runs From Dot YTP+++ plugin.'
        settings = @(
            @{
                name = 'Display Name'
                value = 'Everyone Screams Runs From Dot'
                type = 'label'
            },
            @{
                name = 'Description'
                value = 'Everyone Screams Runs From Dot YTP+++ plugin.'
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
