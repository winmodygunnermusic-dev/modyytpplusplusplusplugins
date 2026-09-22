# YTP+++ PowerShell plugin: Fearful Effect Trims The Clip
# PowerShell-native metadata prevents plugin discovery from parsing Lua syntax.

function Query {
    param($localeName, $localizationTokens)

    return @{
        name = 'Fearful Effect Trims The Clip'
        description = 'YTP-style NVG pixel effect with safe default parameters.'
        settings = @(
            @{
                name = 'Display Name'
                value = 'Fearful Effect Trims The Clip'
                type = 'label'
            },
            @{
                name = 'Description'
                value = 'YTP-style NVG pixel effect with safe default parameters.'
                type = 'label'
            },
            @{
                name = 'amount'
                value = 0.5
                type = 'number'
            },
            @{
                name = 'offset_x'
                value = 0
                type = 'number'
            },
            @{
                name = 'offset_y'
                value = 0
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
