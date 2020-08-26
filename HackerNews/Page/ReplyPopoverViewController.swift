
import Cocoa
import HNAPI

class ReplyPopoverViewController: NSViewController {

    @IBOutlet var commentLabel: NSTextField!
    @IBOutlet var replyTextField: NSTextField!

    @IBOutlet var commentTopConstraint: NSLayoutConstraint!

    var comment: Comment! {
        didSet {
            let textColor: NSColor
            switch comment.color {
            case .c00: textColor = .labelColor
            case .c5a, .c73, .c82: textColor = .secondaryLabelColor
            case .c88, .c9c, .cae: textColor = .tertiaryLabelColor
            case .cbe, .cce, .cdd: textColor = .quaternaryLabelColor
            }
            DispatchQueue.main.async {
                self.commentLabel.attributedStringValue = self.comment.text.styledAttributedString(textColor: textColor)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }

    @IBAction func reply(_ sender: NSButton) {
        let text = replyTextField.stringValue
        guard let token = Account.selectedAccount?.token else {
            return
        }
        APIClient.shared.reply(toID: comment.id, text: text, token: token) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    if self.presentingViewController != nil {
                        self.dismiss(self)
                    } else {
                        self.view.window?.close()
                    }
                case .failure(let error):
                    if self.presentingViewController != nil {
                        self.dismiss(self)
                    } else {
                        self.view.window?.close()
                    }
                    NSApplication.shared.presentError(error)
                }
            }
        }
    }

    @IBAction func cancel(_ sender: NSButton) {
        if self.presentingViewController != nil {
            self.dismiss(self)
        } else {
            self.view.window?.close()
        }
    }
}

extension ReplyPopoverViewController: NSPopoverDelegate {

    func popoverDidDetach(_ popover: NSPopover) {
        commentTopConstraint.animator().constant = 20.0
    }

    func popoverShouldDetach(_ popover: NSPopover) -> Bool {
        true
    }
}

extension NSStoryboard.SceneIdentifier {
    static var replyPopoverViewController = NSStoryboard.SceneIdentifier("ReplyPopoverViewController")
}
