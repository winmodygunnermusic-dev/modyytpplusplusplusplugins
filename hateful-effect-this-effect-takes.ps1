# YTP+++ PowerShell plugin: Hateful Effect This Effect Takes
#
# This script uses PowerShell-native functions and hashtables so the plugin host
# can query its metadata without parsing Lua syntax.

function Query {
    param(
        $localeName,
        $localizationTokens
    )

    return @{
        name = 'Hateful Effect This Effect Takes'
        description = 'Hateful Effect This Effect Takes YTP+++ plugin.'
        settings = @(
            @{
                name = 'Display Name'
                value = 'Hateful Effect This Effect Takes'
                type = 'label'
            },
            @{
                name = 'Description'
                value = 'Hateful Effect This Effect Takes YTP+++ plugin.'
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
