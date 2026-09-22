# YTP+++ PowerShell plugin: Mlg 2012 Meme Effect
#
# This script uses PowerShell-native functions and hashtables so the plugin host
# can query its metadata without parsing Lua syntax.

function Query {
    param(
        $localeName,
        $localizationTokens
    )

    return @{
        name = 'Mlg 2012 Meme Effect'
        description = 'Mlg 2012 Meme Effect YTP+++ plugin.'
        settings = @(
            @{
                name = 'Display Name'
                value = 'Mlg 2012 Meme Effect'
                type = 'label'
            },
            @{
                name = 'Description'
                value = 'Mlg 2012 Meme Effect YTP+++ plugin.'
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
