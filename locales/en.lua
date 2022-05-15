local Translations = {
    text = {
        to_be_finished = "%{actionCount} more jobs need to be done."
    },
    notify = {
        send_to_community_service = "Sent to community service",
        no_player = "Player not available",
        community_service_canceled = "Community service canceled for Player ID: %{playerId}",
        community_service_finished = "Community service finished",
        escape_string = "Don't try to escape, your service period got extended"
    },
    progressbar = {
        cleaning = "Cleaning...",
        gardening = "Trimming...",
    }
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})