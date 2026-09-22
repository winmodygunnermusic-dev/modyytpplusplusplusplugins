# YTP+++ PowerShell plugin: Explosion Spam
#
# This script uses PowerShell-native functions and hashtables so the plugin host
# can query its metadata without parsing Lua syntax.

function Query {
    param(
        $localeName,
        $localizationTokens
    )

    return @{
        name = 'Explosion Spam'
        description = 'Randomly spams explosion clips over the source video.'
        settings = @(
            @{
                name = 'Display Name'
                value = 'Explosion Spam'
                type = 'label'
            },
            @{
                name = 'Description'
                value = 'Randomly spams explosion clips over the source video.'
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
