# YTP+++ PowerShell plugin: Black Hole Add Round Effect
#
# This script uses PowerShell-native functions and hashtables so the plugin host
# can query its metadata without parsing Lua syntax.

function Query {
    param(
        $localeName,
        $localizationTokens
    )

    return @{
        name = 'Black Hole Add Round Effect'
        description = 'Black Hole Add Round Effect YTP+++ plugin.'
        settings = @(
            @{
                name = 'Display Name'
                value = 'Black Hole Add Round Effect'
                type = 'label'
            },
            @{
                name = 'Description'
                value = 'Black Hole Add Round Effect YTP+++ plugin.'
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
