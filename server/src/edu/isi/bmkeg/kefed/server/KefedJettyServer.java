// $Id: KefedJettyServer.java 52 2011-06-15 20:26:38Z taruss2000@gmail.com $
package edu.isi.bmkeg.kefed.server;

import java.awt.BorderLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.File;
import java.io.FilenameFilter;
import java.util.ArrayList;
import java.util.Collection;

import javax.swing.JButton;
import javax.swing.JFormattedTextField;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.SwingUtilities;

import com.jgoodies.forms.builder.ButtonBarBuilder2;
import com.jgoodies.forms.builder.DefaultFormBuilder;
import com.jgoodies.forms.factories.Borders;
import com.jgoodies.forms.layout.FormLayout;

import org.eclipse.jetty.server.Handler;
import org.eclipse.jetty.server.Server;
import org.eclipse.jetty.server.handler.ContextHandlerCollection;
import org.eclipse.jetty.util.component.LifeCycle;
import org.eclipse.jetty.webapp.WebAppContext;

/**
 * The Kefed server application using an embedded Jetty web server.
 * When launched this will present a dialog that will allow the
 * specification of a port for running the server, and start and stop
 * controls.
 *
 * TODO: Add ability to set a user name and password as well.
 *
 * @author University of Southern California
 * @date $Date: 2011-06-15 13:26:38 -0700 (Wed, 15 Jun 2011) $
 * @version $Revision: 52 $
 */
public class KefedJettyServer implements LifeCycle.Listener {

  /** PATH TO APPLICATION */
  private static final String NEURO_URL_PATH = "/blazeds/bioscholar/NeuralConnectivity.html";
  private static final String BIOSCHOLAR_URL_PATH = "/blazeds/bioscholar/BioScholar.html";
  /** Default port to use for initial suggestion */
  private static final int DEFAULT_PORT = 50000;
  /** Minimum and Maximum user settable port values */
  private static final int MIN_NON_ROOT_PORT_VALUE = 1024;
  private static final int MIN_PORT_VALUE = 49152;
  private static final int MAX_PORT_VALUE = 65535;

  private int port = DEFAULT_PORT;
  /** Use this to see if the current port has changed. */
  private int currentServerPort = DEFAULT_PORT;
  private File workingDirectory = new File(System.getProperty("user.home"), "BioScholarServer");

  private Server server = null;
  private String jettyHome;
  private JFrame f;
  private JLabel status;
  private JFormattedTextField portValue;
  private JButton folderButton;
  private JButton urlButton1;
  private JButton urlButton2 = null;
  private JButton startButton;
  private JButton stopButton;
  private JButton quitButton;

  private String name = "Jetty Server";
  private String urlpath1 = "/";
  private String urlpath2 = "/";

  /** Create a new KefedJettyServer to run web applications
   *
   * @param name The name for this application.  Used as title.
   * @param urlpath The path to the first URL to launch for the application
   * @param urlpath The path to the second URL to launch for the application (may be null)
   */
  public KefedJettyServer (String name, String urlpath1, String urlpath2) {
    this.name = name;
    this.urlpath1 = urlpath1;
    this.urlpath2 = urlpath2;
    jettyHome = System.getProperty("jetty.home",".");
    SwingUtilities.invokeLater(new Runnable () {
    	public void run () {
    		buildInterface();
    		}
      });
  }

  private boolean isValidPort(JFormattedTextField portField) {
  	if (portField.isValid()) {
  		int port = ((Integer) portField.getValue()).intValue();
  		return port >= MIN_NON_ROOT_PORT_VALUE && port <= MAX_PORT_VALUE;
  	} else {
  		return false;
  	}
  }

  private String buildUrl (int urlport, String urlpath) {
  	return "http://localhost:" + urlport + urlpath;
  }

  private void buildInterface() {
    f = new JFrame(name);
    f.setLayout(new BorderLayout());

    JPanel p = new JPanel();
    p.setBorder(Borders.DIALOG_BORDER);
    p.setLayout(new BorderLayout());

    FormLayout layout = new FormLayout("right:[40dlu,pref], 3dlu, left:[40dlu,pref]");
    DefaultFormBuilder builder = new DefaultFormBuilder(layout);
    builder.setDefaultDialogBorder();
    ButtonBarBuilder2 bbuilder = new ButtonBarBuilder2();

    portValue = new JFormattedTextField(new Integer(port));
    portValue.setColumns(5);
    portValue.setToolTipText("Should be between " + MIN_PORT_VALUE + " and " + MAX_PORT_VALUE);

    status = new JLabel("Stopped");

    ActionListener urlListener = new ActionListener() {
    	public void actionPerformed(ActionEvent e) {
	  try {
	    java.awt.Desktop.getDesktop().browse(java.net.URI.create(((JButton)(e.getSource())).getText()));
	  } catch (Exception e1) {
	    reportError(e1);
	  }
    	}
      };
    urlButton1 = new JButton(buildUrl(port, urlpath1));
    urlButton1.setEnabled(false);
    urlButton1.addActionListener(urlListener);
    if (urlpath2 != null) {
      urlButton2 = new JButton(buildUrl(port, urlpath2));
      urlButton2.setEnabled(false);
      urlButton2.addActionListener(urlListener);
    }


    startButton = new JButton("Start Server");
    startButton.setEnabled(true);
    startButton.addActionListener(new ActionListener() {
    	public void actionPerformed(ActionEvent e) {
	  if (!workingDirectory.exists()) {
	    JOptionPane.showMessageDialog(f, "The directory \"" + workingDirectory.getPath()
					  + "\" will be created to hold server files and store information.",
					  "Notice", JOptionPane.INFORMATION_MESSAGE);
	    workingDirectory.mkdirs();
	    new File(workingDirectory,"work").mkdir();
	  }
	  if (isValidPort(portValue)) {
	    port = ((Integer) portValue.getValue()).intValue();
	    urlButton1.setText(buildUrl(port, urlpath1));
	    if (urlButton2 != null) urlButton2.setText(buildUrl(port, urlpath2));
	    start(port);
	    startButton.setEnabled(false);
	    portValue.setEditable(false);
	  } else {
	    JOptionPane.showMessageDialog(f, "Port value must be a number, usually between "
					  + MIN_PORT_VALUE + " and " + MAX_PORT_VALUE,
					  "Error", JOptionPane.ERROR_MESSAGE);

    			}
    	}
    });

    stopButton = new JButton("Stop Server");
    stopButton.setEnabled(false);
    stopButton.addActionListener(new ActionListener() {
    	public void actionPerformed(ActionEvent e) {
	  new Thread () {
	    @Override
	      public void run () {
	      try {
		server.stop();
	      } catch (Exception e1) {
		reportError(e1);
	      }
	    }
	  }.start();
	  stopButton.setEnabled(false);
	  urlButton1.setEnabled(false);
	  if (urlButton2 != null) urlButton2.setEnabled(false);
	  portValue.setEditable(true);
    	}
    });

    quitButton = new JButton("Quit");
    quitButton.setEnabled(true);
    quitButton.addActionListener(new ActionListener() {
    	public void actionPerformed(ActionEvent e) {
    			if (server != null && server.isRunning()) {
    				try {
							server.stop();
						} catch (Exception e1) {
							// Do nothing, we are exiting the application.
						}
    			}
    			System.exit(0);
    	}
    });

    builder.append("Port:", portValue);
    // builder.append("Working Folder:", folderButton);
    builder.appendParagraphGapRow();
    builder.append("Status:", status);
    if (urlButton2 == null) {
      builder.append("App:", urlButton1);
    } else {
      builder.append("App 1:", urlButton1);
      builder.append("App 2:", urlButton2);
    }

    bbuilder.addButton(startButton);
    // This doesn't properly shutdown the persevere war, so disable it.
    // bbuilder.addButton(stopButton);
    bbuilder.addUnrelatedGap();
    bbuilder.addGlue();
    bbuilder.addButton(quitButton);

    p.add(new JLabel("<html><b>BioScholar Jetty Server</b></html>"), BorderLayout.NORTH);
    p.add(builder.getPanel(), BorderLayout.CENTER);
    p.add(bbuilder.getPanel(), BorderLayout.SOUTH);

    f.add(p, BorderLayout.CENTER);

    f.pack();
    f.setVisible(true);
  }

  public void start (int onPort) {
    if (server == null || currentServerPort != onPort) {
      server = new Server(onPort);
      server.addLifeCycleListener(this);
      currentServerPort = onPort;
      status.setText("Creating Server...");
      new Thread() {
	@Override
	  public void run () {
	  try {
	    Collection<Handler> handlers = new ArrayList<Handler>();
	    // Set this up so we can find the crossdomain.xml file
	    // that we need in order to have the WebApps interoperate.
	    WebAppContext root = new WebAppContext();
	    root.setContextPath("/");
	    root.setResourceBase(jettyHome + "/webapps/root");
	    handlers.add(root);

	    // Setup all items in the webapps directory which
	    // have war files to be part of the server.
	    File webappDirectory = new File(jettyHome + "/webapps");
	    assert webappDirectory.isDirectory() : webappDirectory.getCanonicalPath();
	    File tempDirectory = new File(workingDirectory, "work");
	    assert tempDirectory.isDirectory() : tempDirectory.getCanonicalPath();
	    FilenameFilter warFilter = new FilenameFilter() {
		public boolean accept(File dir, String name) {
		  return name.endsWith(".war");
		}
	      };

	    for (File warFile: webappDirectory.listFiles(warFilter)) {
	      String filename = warFile.getName();
	      int dotPosition = filename.lastIndexOf('.');
	      WebAppContext c = new WebAppContext();
	      c.setContextPath("/" + filename.substring(0,dotPosition));
	      c.setWar(warFile.getCanonicalPath());
	      c.setTempDirectory(new File(tempDirectory, filename));
	      handlers.add(c);
	    }

	    ContextHandlerCollection contexts = new ContextHandlerCollection();
	    contexts.setHandlers(handlers.toArray(new Handler[0]));
	    server.setHandler(contexts);

	    server.start();
	  } catch (Exception e) {
	    reportError(e);
	    e.printStackTrace();
	  }
	}
      }.start();
    } else { // The existing server has the correct port, so we just start it.
      new Thread() {
	@Override
	  public void run () {
	  try {
	    server.start();
	  } catch (Exception e) {
	    reportError(e);
	    e.printStackTrace();
	  }
	}
      }.start();
    }
  }

  /** General error reporting pop-up.
   * @param error The Throwable that we are reporting.
   */
  private void reportError (final Throwable error) {
    SwingUtilities.invokeLater(new Runnable() {
	public void run () {
	  JOptionPane.showMessageDialog(f, error.getMessage(), "Error",
					JOptionPane.ERROR_MESSAGE);
	}
      });
  }


	/* (non-Javadoc)
	 * @see org.eclipse.jetty.util.component.LifeCycle.Listener#lifeCycleFailure(org.eclipse.jetty.util.component.LifeCycle, java.lang.Throwable)
	 */
	@Override
	public void lifeCycleFailure (LifeCycle lc, Throwable error) {
		reportError(error);
	}


  /* (non-Javadoc)
   * @see org.eclipse.jetty.util.component.LifeCycle.Listener#lifeCycleStarted(org.eclipse.jetty.util.component.LifeCycle)
   */
  @Override
    public void lifeCycleStarted (LifeCycle lc) {
    SwingUtilities.invokeLater(new Runnable() {
	public void run () {
	  status.setText("Running");
	  quitButton.setText("Stop and Quit");
	  stopButton.setEnabled(true);
	  urlButton1.setEnabled(true);
	  if (urlButton2 != null) urlButton2.setEnabled(true);
	}
      });
  }

  /* (non-Javadoc)
   * @see org.eclipse.jetty.util.component.LifeCycle.Listener#lifeCycleStarting(org.eclipse.jetty.util.component.LifeCycle)
   */
  @Override
    public void lifeCycleStarting (LifeCycle lc) {
    SwingUtilities.invokeLater(new Runnable() {
	public void run () {
	  status.setText("Starting...");
	}
      });
  }

  /* (non-Javadoc)
   * @see org.eclipse.jetty.util.component.LifeCycle.Listener#lifeCycleStopped(org.eclipse.jetty.util.component.LifeCycle)
   */
  @Override
    public void lifeCycleStopped (LifeCycle lc) {
    SwingUtilities.invokeLater(new Runnable() {
	public void run () {
	  status.setText("Stopped");
	  quitButton.setText("Quit");
	  startButton.setEnabled(true);
	  portValue.setEditable(true);
	}
      });
  }

  /* (non-Javadoc)
   * @see org.eclipse.jetty.util.component.LifeCycle.Listener#lifeCycleStopping(org.eclipse.jetty.util.component.LifeCycle)
   */
  @Override
    public void lifeCycleStopping (LifeCycle lc) {
    SwingUtilities.invokeLater(new Runnable() {
	public void run () {
	  status.setText("Stopping...");
	}
      });
  }


  /**
   * Launches an interface to control a web server serving
   * the KefedEditor for BioScholar.
   *
   * @param args a <code>String</code> value
   * @exception Exception if an error occurs
   */
  public static void main(String[] args) throws Exception {
    new KefedJettyServer("BioScholar Jetty Server", NEURO_URL_PATH, BIOSCHOLAR_URL_PATH);
  }
}
