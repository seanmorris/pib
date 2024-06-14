<?php
use function Cake\Core\h;
?>
<?php foreach ($mailPreviews as $plugin => $previews) : ?>
<h3><?= $plugin ?></h3>
    <?php foreach ($previews as $preview) : ?>
        <?php $mailPreview = $preview['class'] ?>
        <h4><?= "\u{2709}\u{FE0F}" ?> <?= h($mailPreview->name()) ?></h4>
        <table cellpadding="0" cellspacing="0">
            <tbody>
            <?php foreach ($mailPreview->getEmails() as $email) : ?>
                <tr>
                    <td>
                    <?php
                        echo $this->Html->link($email, [
                            'controller' => 'MailPreview',
                            'action' => 'email',
                            '?' => ['plugin' => $plugin],
                            $mailPreview->name(),
                            $email,
                        ]);
                    ?>
                    </td>
                </tr>
            <?php endforeach; ?>
            </tbody>
        </table>
    <?php endforeach; ?>
<?php endforeach; ?>

<div style="font-weight:300;margin-top:100px">
    <h3>How to use this feature?</h3>
    <p>Testing emails can be very time consuming &#8987;</p>
    <p>Specially when you need to click a bunch of times on an interface to trigger them.</p>
    <p>Wouldn't it be better to just change the templates and refresh the browser to see the result?</p>
    <p>Just the way you work on the web interface! &#127939;</p>

    <h4>Example</h4>
    <p>MailPreview integrates with CakePHP’s Mailer class. Here's an example of such a mailer:</p>

    <pre style="background-color:#f8f8f8;font-family:Monaco,monospace;overflow:scroll;margin:10px 0;line-height:25px;">
    <?php
        $code = '
    <?php
        namespace App\Mailer;

        use Cake\Mailer\Mailer;

        class UserMailer extends Mailer
        {
            public function welcome($user)
            {
                $mailer = $this->setTo($user->email)
                    ->setSubject(sprintf("Welcome %s", $user->name))
                    ->setViewVars(["user" => $user]);
                $mailer->viewBuilder()
                    ->setTemplate("welcome_mail") // By default template with same name as method name is used.
                    ->setLayout("custom");
                return $mailer;
            }
        }';
        highlight_string($code);
    ?>
    </pre>
    <p>Now you create a MailPreview class where you can pass some dummy values.</p>

    <pre style="background-color:#f8f8f8;font-familiy:Monaco,sans-serif;overflow:scroll;margin:10px 0;line-height:25px;">
    <?php
        $code = '
    <?php
        // Create the file src/Mailer/Preview/UserMailPreview.php
        namespace App\Mailer\Preview;

        use DebugKit\Mailer\MailPreview;

        class UserMailPreview extends MailPreview
        {
            public function welcome()
            {
                $this->loadModel("Users");
                $user = $this->Users->find()->first();

                return $this->getMailer("User")
                    ->welcome($user)
                    ->setViewVars(["activationToken" => "dummy-token"]);
            }
        }';
        highlight_string($code);
    ?>
    </pre>

    <p>Note that the function MUST return the UserMailer object at the end.</p>
    <p>Since Mailers have a fluent interface, you just need to return the result of the chain of calls.</p>
    <p style="margin:20px 0">That's it, now refresh this page! &#128579;</p>
</div>
