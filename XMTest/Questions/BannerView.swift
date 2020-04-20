import UIKit
import SnapKit

class BannerView: UIView {
    private let banner = UIView()
    private let label = UILabel()
    private let button = UIButton(type: .custom).with {
        $0.setTitle("Retry", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.setTitleColor(.lightGray, for: .highlighted)
        $0.backgroundColor = .clear
        $0.contentEdgeInsets = UIEdgeInsets(top: 8, left: 32, bottom: 8, right: 32)
        $0.layer.cornerRadius = 4
        $0.layer.borderColor = UIColor.lightGray.cgColor
        $0.layer.borderWidth = 1
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.black.withAlphaComponent(0.2)

        setupBanner()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureBanner(
        for state: QuestionsView.BannerState,
        retryTarget: Any?,
        retrySelector: Selector
    ) {
        button.addTarget(retryTarget, action: retrySelector, for: .primaryActionTriggered)

        switch state {
        case .failure:
            banner.backgroundColor = .red
            button.isHidden = false
            label.text = "Failure!"
        case .success:
            banner.backgroundColor = .green
            button.isHidden = true
            label.text = "Success"
        }
    }

    private func setupBanner() {
        let stack = UIStackView(arrangedSubviews: [label, button]).with {
            $0.axis = .horizontal
            $0.distribution = .equalSpacing
            $0.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            $0.isLayoutMarginsRelativeArrangement = true
        }

        banner.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.width.equalTo(banner)
            make.centerY.equalTo(banner)
            make.height.equalTo(32)
        }

        addSubview(banner)
        banner.snp.makeConstraints { make in
            make.width.equalTo(self)
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top)
            make.height.equalTo(128)
        }
    }
}
