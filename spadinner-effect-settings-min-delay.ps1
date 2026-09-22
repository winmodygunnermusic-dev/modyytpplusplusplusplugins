# YTP+++ PowerShell plugin: Spadinner Effect Settings Min Delay
# PowerShell-native metadata prevents plugin discovery from parsing Lua syntax.

function Query {
    param($localeName, $localizationTokens)

    return @{
        name = 'Spadinner Effect Settings Min Delay'
        description = 'YTP-style NVG pixel effect with safe default parameters.'
        settings = @(
            @{
                name = 'Display Name'
                value = 'Spadinner Effect Settings Min Delay'
                type = 'label'
            },
            @{
                name = 'Description'
                value = 'YTP-style NVG pixel effect with safe default parameters.'
                type = 'label'
            },
            @{
                name = 'minDelay'
                value = 0.1
                type = 'number'
            },
            @{
                name = 'maxDelay'
                value = 0.75
                type = 'number'
            },
            @{
                name = 'minSFXCount'
                value = 5
                type = 'number'
            },
            @{
                name = 'maxSFXCount'
                value = 10
                type = 'number'
            },
            @{
                name = 'useSpadinnerLibrary'
                value = 1
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
