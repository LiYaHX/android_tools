# !/usr/bin/python
# -*- coding: utf-8 -*-

# import smtplib
from smtplib import SMTP, quotedata, CRLF, SMTPDataError
from email import encoders
from email.header import Header
from email.mime.text import MIMEText
from email.utils import parseaddr, formataddr
from email.mime.multipart import MIMEMultipart
from email.mime.base import MIMEBase
from sys import stderr, stdout
import os,sys, time

class ExtendedSMTP(SMTP):
  def data(self, msg):
    self.putcmd("data")
    (code,repl)=self.getreply()
    if self.debuglevel > 0 : print >> stderr, "data:", (code, repl)
    if code != 354:
      raise SMTPDataError(code,repl)
    else:
      q = quotedata(msg)
      if q[-2:] != CRLF:
        q = q + CRLF
      q = q + "." + CRLF

      # begin modified send code
      chunk_size = 2048
      bytes_sent = 0

      while bytes_sent != len(q):
        chunk = q[bytes_sent:bytes_sent+chunk_size]
        self.send(chunk)
        bytes_sent += len(chunk)
        if hasattr(self, "callback"):
          self.callback(bytes_sent, len(q))
      # end modified send code

      (code,msg)=self.getreply()
      if self.debuglevel >0 : print>>stderr, "data:", (code,msg)
      return (code,msg)


def sendMail(filePath, fileName, appName):
    def _format_addr(s):
        name, addr = parseaddr(s)
        return formataddr(( \
            Header(name, 'utf-8').encode(), \
            addr.encode('utf-8') if isinstance(addr, unicode) else addr))

    def callback(progress, total):
          percent = 100. * progress / total
          stdout.write('\r')
          stdout.write("%s bytes sent of %s [%2.0f%%]" % (progress, total, percent))
          stdout.flush()
          if percent >= 100: stdout.write('\n')

    #注：当遇到smtplib.SMTPAuthenticationError: (535, '5.7.8 authentication failed')异常时，（1）检查邮件帐号、密码是否正确；（2）确认发送邮箱是否需要第三方客户端邮箱授权码
    #参数配置
    from_addr = "send_email_address"
    password = "send_email_password"
    to_addr = ["receive_email_address"]
    #eg:smtp_server = "smtp.sina.com"
    smtp_server = "smtp.send_email_address_domain"

    #邮件信息配置
    #正文
    content = u'%s新版本(版本号)的安装包已发送，请将本版本的需要变更之处用文本记录下来发送给本人，谢谢🙏'% sys.argv[3]
    #标题（使用传输过来的数据）
    subject = u'%s的安装包' % sys.argv[3]
    emailFrom = "鶸开发RL"
    msg = MIMEMultipart()
    msg['From'] = _format_addr('%s<%s>' % (emailFrom,from_addr))
    msg['To'] = _format_addr(u'接受者 <%s>' % to_addr)
    msg['Subject'] = Header('%s' % subject, 'utf-8').encode()
    msg.attach(MIMEText('%s'%content, 'plain', 'utf-8'))

    mime = MIMEBase('application', 'octet-stream', filename=fileName)
    with open(filePath, 'rb') as f:
        # 加上必要的头信息:
        mime.add_header('Content-Disposition', 'attachment', filename=fileName)
        mime.add_header('Content-ID', '<0>')
        mime.add_header('X-Attachment-Id', '0')
        mime.set_payload(f.read())
        # 用Base64编码:
        encoders.encode_base64(mime)
        # 添加到MIMEMultipart:
        msg.attach(mime)

    try:
        server = ExtendedSMTP()
        server.callback = callback
        server.connect(smtp_server, 25)
        # server.set_debuglevel(1)#坑爹的调试模式，打开输出一万行坑了我四天
        server.login(from_addr, password)
        server.sendmail(from_addr, to_addr, msg.as_string())
        server.quit()
        return True
    except Exception as e:
        raise e
        return False


if __name__ == '__main__':

    # print sys.argv
    if sendMail(sys.argv[1], sys.argv[2], sys.argv[3]):
        print "\033[32;1m 邮件已发送!\033[0m"
    else:
        print "邮件发送失败!"
