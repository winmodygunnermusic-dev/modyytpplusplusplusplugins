# YTP+++ PowerShell plugin: Frame-by-Frame Masking
#
# This script uses PowerShell-native functions and hashtables so the plugin host
# can query its metadata without parsing Lua syntax.

function Query {
    param(
        $localeName,
        $localizationTokens
    )

    return @{
        name = 'Frame-by-Frame Masking'
        description = 'Applies an animated frame-by-frame geometric mask that changes position, size, and rotation.'
        settings = @(
            @{
                name = 'Display Name'
                value = 'Frame-by-Frame Masking'
                type = 'label'
            },
            @{
                name = 'Description'
                value = 'Applies an animated frame-by-frame geometric mask that changes position, size, and rotation.'
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
