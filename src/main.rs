use dbus::blocking::LocalConnection;

fn main() {
    env_logger::init();
    let path_to_script =
        std::env::var("AUTOTHEME_SCRIPT").unwrap_or_else(|_| "./autotheme.bash".to_string());
    let con = LocalConnection::new_session().unwrap();

    let rule =
        dbus::message::MatchRule::new().with_sender("org.freedesktop.impl.portal.desktop.gnome");
    let script = path_to_script.clone();
    con.add_match(rule, move |_: (), _, message| {
        log::info!("Received message from GNOME Portal: {:?}", message);
        log::info!("Changing theme...");
        std::process::Command::new(&path_to_script)
            .spawn()
            .unwrap()
            .wait_with_output()
            .unwrap();
        true
    })
    .unwrap();

    con.add_match(
        dbus::message::MatchRule::new()
            .with_interface("ca.desrt.dconf.Writer")
            .with_member("Notify"),
        move |_: (), _, message| {
            log::info!("Received message from dconf: {:?}", message);

            if message.get1() == Some("/org/gnome/desktop/background") {
                log::info!("Changing theme...");
                std::process::Command::new(&script)
                    .spawn()
                    .unwrap()
                    .wait_with_output()
                    .unwrap();
            }

            true
        },
    )
    .unwrap();

    con.set_signal_match_mode(true);

    loop {
        con.process(std::time::Duration::from_secs(100)).unwrap();
        println!("Waiting for signal...");
    }
}
