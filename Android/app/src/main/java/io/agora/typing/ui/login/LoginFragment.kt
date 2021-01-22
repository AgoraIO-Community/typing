package io.agora.typing.ui.login

import androidx.lifecycle.ViewModelProvider
import android.os.Bundle
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.EditText
import android.widget.ProgressBar
import androidx.lifecycle.observe
import io.agora.typing.ui.ChatActivity
import io.agora.typing.R
import com.google.android.material.snackbar.Snackbar
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.FlowPreview

@ExperimentalCoroutinesApi
@FlowPreview
class LoginFragment : Fragment() {

    companion object {
        fun newInstance() = LoginFragment()
    }

    private lateinit var viewModel: LoginModel
    private lateinit var userInput: EditText
    private lateinit var friendInput: EditText
    private lateinit var startButton: Button
    private lateinit var progressBar: ProgressBar

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        val root = inflater.inflate(R.layout.login_fragment, container, false)
        userInput = root.findViewById(R.id.user)
        friendInput = root.findViewById(R.id.friend)
        startButton = root.findViewById(R.id.start)
        progressBar = root.findViewById(R.id.connecting)
        return root
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        viewModel = ViewModelProvider(this).get(LoginModel::class.java)

        startButton.setOnClickListener {
            viewModel.userName = userInput.text.toString()
            viewModel.friendName = friendInput.text.toString()
            viewModel.onClickLoginButton()
        }

        viewModel.online.observe(this) { success ->
            if (success) {
                //startActivity()
                context?.let { _context ->
                    viewModel.friendName?.let { _name ->
                        startActivity(ChatActivity.newInstance(_context, _name))
                    }
                }
            }
        }

        viewModel.spinner.observe(this) { value ->
            value.let { show ->
                userInput.isEnabled = !show
                friendInput.isEnabled = !show
                progressBar.visibility = if (show) View.VISIBLE else View.INVISIBLE
                startButton.visibility = if (show) View.INVISIBLE else View.VISIBLE
            }
        }

        // Show a snackbar whenever the [ViewModel.snackbar] is updated a non-null value
        viewModel.snackbar.observe(this) { text ->
            text?.let {
                this.view?.let { it1 -> Snackbar.make(it1, it, Snackbar.LENGTH_SHORT).show() }
                viewModel.onSnackbarShown()
            }
        }
    }

}