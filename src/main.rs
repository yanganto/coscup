#[cfg(test)]
mod tests;

use neovim_lib::{Neovim, NeovimApi, Session};
use notify_rust::Notification;

enum Messages {
    Coscup,
    Unknown(String),
}

impl From<String> for Messages {
    fn from(event: String) -> Self {
        match &event[..] {
            "Coscup" => Messages::Coscup,
            _ => Messages::Unknown(event),
        }
    }
}

struct EventHandler {
    nvim: Neovim,
}

impl EventHandler {
    fn new() -> EventHandler {
        let session = Session::new_parent().unwrap();
        let nvim = Neovim::new(session);

        EventHandler { nvim }
    }

    fn recv(&mut self) {
        let receiver = self.nvim.session.start_event_loop_channel();

        for (event, values) in receiver {
            match Messages::from(event) {
                Messages::Coscup => {
                    self.nvim
                        .command(&format!(r#"echo "{}""#, values[0].as_str().unwrap_or("Unexpect value")))
                        .unwrap();
                }
                Messages::Unknown(event) => {
                    Notification::new()
                        .summary("coscup")
                        .body(&format!("Unknown command: {}", event))
                        .show()
                        .unwrap();
                }
            }
        }
    }
}

fn main() {
    let mut event_handler = EventHandler::new();
    event_handler.recv();
}
