# YTP+++ PowerShell plugin: Single Material Spam
#
# This script uses PowerShell-native functions and hashtables so the plugin host
# can query its metadata without parsing Lua syntax.

function Query {
    param(
        $localeName,
        $localizationTokens
    )

    return @{
        name = 'Single Material Spam'
        description = 'Spams one material/color overlay repeatedly throughout the video.'
        settings = @(
            @{
                name = 'Display Name'
                value = 'Single Material Spam'
                type = 'label'
            },
            @{
                name = 'Description'
                value = 'Spams one material/color overlay repeatedly throughout the video.'
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
