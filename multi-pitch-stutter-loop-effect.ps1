# YTP+++ PowerShell plugin: Multi Pitch Stutter Loop Effect
# PowerShell-native metadata prevents plugin discovery from parsing Lua syntax.

function Query {
    param($localeName, $localizationTokens)

    return @{
        name = 'Multi Pitch Stutter Loop Effect'
        description = 'YTP-style NVG pixel effect with safe default parameters.'
        settings = @(
            @{
                name = 'Display Name'
                value = 'Multi Pitch Stutter Loop Effect'
                type = 'label'
            },
            @{
                name = 'Description'
                value = 'YTP-style NVG pixel effect with safe default parameters.'
                type = 'label'
            },
            @{
                name = 'speed'
                value = 10.0
                type = 'number'
            },
            @{
                name = 'depth'
                value = 2.0
                type = 'number'
            }
        )
    }
}

function run {
    param($state)

    if ($null -eq $state) {
        return $null
    }

    return @($state.r, $state.g, $state.b)
}
