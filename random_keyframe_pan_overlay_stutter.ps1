# YTP+++ PowerShell plugin: Random Keyframe Pan Overlay Stutter
#
# This script uses PowerShell-native functions and hashtables so the plugin host
# can query its metadata without parsing Lua syntax.

function Query {
    param(
        $localeName,
        $localizationTokens
    )

    return @{
        name = 'Random Keyframe Pan Overlay Stutter'
        description = 'Random Keyframe Pan Overlay Stutter YTP+++ plugin.'
        settings = @(
            @{
                name = 'Display Name'
                value = 'Random Keyframe Pan Overlay Stutter'
                type = 'label'
            },
            @{
                name = 'Description'
                value = 'Random Keyframe Pan Overlay Stutter YTP+++ plugin.'
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
