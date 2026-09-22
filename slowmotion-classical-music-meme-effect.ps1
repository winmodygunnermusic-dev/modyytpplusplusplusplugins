# YTP+++ PowerShell plugin: Slowmotion Classical Music Meme Effect
#
# This script uses PowerShell-native functions and hashtables so the plugin host
# can query its metadata without parsing Lua syntax.

function Query {
    param(
        $localeName,
        $localizationTokens
    )

    return @{
        name = 'Slowmotion Classical Music Meme Effect'
        description = 'YTP-style NVG pixel effect with safe default parameters.'
        settings = @(
            @{
                name = 'Display Name'
                value = 'Slowmotion Classical Music Meme Effect'
                type = 'label'
            },
            @{
                name = 'Description'
                value = 'YTP-style NVG pixel effect with safe default parameters.'
                type = 'label'
            }
        )
    }
}

function run {
    param($state)

    if ($null -eq $state) {
        return $null
    }

    # Preserve the source pixel when a legacy pixel-effect hook is invoked.
    return @($state.r, $state.g, $state.b)
}
